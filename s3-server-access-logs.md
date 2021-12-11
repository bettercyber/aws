# Monitoring AWS S3 Server Access Logs with Wazuh

This document covers the following steps:

1. Create a bash script on the Wazuh Manager to download S3 server access log files from a specified AWS S3 bucket. 
2. Configure Wazuh's command wodle to execute the script every 10 minutes.
3. Configure Wazuh to monitor and analyze the S3 server access log files. 
4. Configure custom decoders to parse the S3 server access logs.
5. Configure custom rules to alert on abnormal S3 server access.

## Configure the Bash Script

The s3accesslogs.sh bash script downloads new files from the specified AWS S3 bucket to the specified subdirectory. 

The following commands create a new file named s3accesslogs.sh, copy the bash script to the new file, and make the file executable. Replace $BUCKET_NAME and $FOLDER_NAME with the bucket and folder names. 

```
mkdir ~/s3accesslogs
touch s3accesslogs.sh
echo "#!/bin/bash
aws s3 sync s3://$BUCKET_NAME/$FOLDER_NAME/ ~/s3accesslogs" > s3accesslogs.sh
chmod +x s3accesslogs.sh
```
Run the following command to test the script:
```
./s3accesslogs.sh
```

## Execute the Script in Wazuh

The command wodle will be used to execute the script every 10 minutes. Copy the following configuration to /var/ossec/etc/ossec.conf. The command assumes that the s3accesslogs.sh script is in the root directory (/root/s3accesslogs.sh). 
```
<wodle name="command">
    <disabled>no</disabled>
    <tag>s3accesslog-files</tag>
    <command>/bin/bash /root/s3accesslogs.sh</command>
    <interval>10m</interval>
    <ignore_output>no</ignore_output>
    <run_on_start>yes</run_on_start>
    <timeout>0</timeout>
</wodle>
```

## Configure Wazuh to Read the S3 Server Access Log Files

Add the following configuration to /var/ossec/etc/ossec.conf to monitor S3 server access logs. The command assumes that the S3 server access log files are in the /root/s3accesslogs directory. 

```
<localfile>
    <log_format>syslog</log_format>
    <location>/root/s3accesslogs/*.txt</location>
</localfile>
```

## Configure Custom Decoders

Add the following custom decoders at the end of /var/ossec/etc/decoders/local_decoder.xml and restart the Wazuh Manager. 

```
<!-- S3 server access log format:
  - <bucket_owner> <bucket> <time> <remote-ip> <requester> <requester_id> <operation> <key> <request-uri> <http-status-code> <error-code> <bytes-sent> <object-size> <total-time> <turn-around-time> <referer> <user-agent> <version-id> <host-id> <signature-version> <cipher-suite> <authentication-type> <host-header> <tls-version> <ARN>
  - bucket_owner: \S+
  - bucket: \S+
  - time: \[\d+\/\w+\/\d+\:\d+\:\d+\:\d+ \+\d+\]
  - remote-ip: \d+\.\d+\.\d+\.\d+
  - requester: \S+
  - requester_id: \S+
  - operation: \w+\.\w+\.\w+
  - key: \S+
  - request-uri: \"\w+ \/\S+ HTTP\/\d+\.\d+\"
  - http-status-code: \d+
  - error-code: \S+
  - bytes-sent: \d+
  - object-size: \d+
  - total-time: \d+
  - turn-around-time: \d+
  - referer: \"(http|https)\:\/\/\S+\"
  - user-agent: \"\S+\"
  - version-id: \S+
  - host-id: \S+
  - signature-version: \S+
  - cipher-suite: \S+
  - authentication-type: \S+
  - host-header: \S+
  - tls-version: \S+
  - ARN: \S+
  -->
  
<decoder name="s3-server-access-log-date">
  <prematch>^\w+ \S+ [\d+/\w+/\d+:\d+:\d+:\d+ \p\d+] </prematch>
  <!-- 70e3c6002de77e45aea5d6cfc88c8e716c2b452aa56c776b0f82b211105dafe0 introxl-db-backups [09/Dec/2021:14:38:45 +0000] -->
</decoder>

<decoder name="s3-server-access-log">
    <type>syslog</type>
    <parent>s3-server-access-log-date</parent>
    <regex>^(\w+) (\S+) [\d+/\w+/\d+:\d+:\d+:\d+ \p\d+] (\d+.\d+.\d+.\d+) (\S+) \w+ (\S+.\S+.\S+) (\S+) ("\w+ /\S+ HTTP/\d+.\d+") (\d+) (\S+) (\S+) \S+ \S+ \S+ ("\S+") ("\.+") \S+ \S+ \S+ \S+ (\S+) (\S+) \S+ (\S+)</regex>
    <order>dstuser, bucketname, srcip, srcuser, operation, key, url, status, action, bytes, referer, useragent, authtype, hostheader, arn</order>
</decoder>
```

## Configure Custom Rules

Add the following rules at the end of /var/ossec/etc/rules/local_rules.xml and restart the Wazuh Manager. 

```
<!--
ID: 100200 - 100299
-->

<group name="aws,s3">

    <rule id="100200" level="0">
        <decoded_as>s3-server-access-log-date</decoded_as>
        <description>AWS S3 server access log messages grouped.</description>
    </rule>

    <rule id="100201" level="0">
        <if_sid>100200</if_sid>
        <field name="statuscode">200</field>
        <description>AWS S3 Server Access: successful access to $(bucketname).</description>
    </rule>

    <rule id="100202" level="0">
        <if_sid>100201</if_sid>
        <field name="operation">\S+.GET.\S+</field>
        <description>AWS S3 Server Access: Successful file download from $(bucketname).</description>
    </rule>
    
    <rule id="100203" level="3">
        <if_sid>100202</if_sid>
        <field name="username">^arn:aws:iam::170804311284</field>
        <description>AWS S3 Server Access: Successful authenticated file download from $(bucketname).</description>
    </rule>

    <rule id="100204" level="15">
        <if_sid>100202</if_sid>
        <field name="username">-</field>
        <description>AWS S3 Server Access: Successful unauthenticated access to $(bucketname).</description>
    </rule>

    <rule id="100205" level="5">
        <if_sid>100200</if_sid>
        <field name="statuscode">^4</field>
        <description>AWS S3 Server Access: Failed access to $(bucketname).</description>
    </rule>
    
    <rule id="100206" level="10" frequency="10" timeframe="120" ignore="60">
        <if_matched_sid>100205</if_matched_sid>
        <same_source_ip />
        <description>AWS S3 Server Access: Multiple failed access to $(bucketname) from the same source.</description>
    </rule>
    
    <rule id="100207" level="10" frequency="10" timeframe="120" ignore="60">
        <if_matched_sid>100205</if_matched_sid>
        <same_srcuser />
        <description>AWS S3 Server Access: Multiple failed access to $(bucketname) by the same user.</description>
    </rule>
    
    <rule id="100208" level="10">
        <if_sid>100203</if_sid>
        <time>7 pm - 7:00 am</time>
        <description>AWS S3 Server Access: Successful authenticated file download from $(bucketname) after hours.</description>
    </rule>

    <rule id="100209" level="12" frequency="10" timeframe="120" ignore="60">
        <if_matched_sid>100208</if_matched_sid>
        <same_srcuser />
        <description>AWS S3 Server Access: Multiple successful authenticated file downloads from $(bucketname) after hours by the same user.</description>
    </rule>
   
    <rule id="100210" level="12" frequency="10" timeframe="120" ignore="60">
        <if_matched_sid>100208</if_matched_sid>
        <same_source_ip />
        <description>AWS S3 Server Access: Multiple successful authenticated file downloads from $(bucketname) after hours from the same source.</description>
    </rule>
   
</group>
```
