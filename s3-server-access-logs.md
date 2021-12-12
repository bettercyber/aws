# Monitoring AWS S3 Server Access Logs with Wazuh

This document covers the following steps:

1. Create a bash script on the Wazuh Manager to download S3 server access log files from a specified AWS S3 bucket. 
2. Configure Wazuh's command wodle to execute the script every 10 minutes.
3. Configure Wazuh to monitor and analyze the S3 server access log files. 
4. Configure custom rules to alert on abnormal S3 server access.

## Configure the Bash Script

The s3accesslogs.sh bash script downloads new files from the specified AWS S3 bucket to the specified subdirectory. 

The following commands create a new file named s3accesslogs.sh, copy the bash script to the new file, and make the file executable. Replace $BUCKET_NAME and $FOLDER_NAME with the bucket and folder names. 

```
mkdir ~/s3accesslogs
touch s3accesslogs.sh
echo "#/bin/bash sqlaudit.sh 
aws s3 sync s3://bastionpod.s3logs/ ~/s3accesslogs
S3FILES=$(find ~/s3accesslogs -mmin -2 | grep txt)
for s3file in $S3FILES ; do
jq -R -n -c '[inputs|split(" ")|{("bucket-owner"):(.[0]),("bucket-name"):(.[1]),("time"):(.[2]),("remote-ip"):(.[3]),("requester"):(.[4]),("requester-id"):(.[5]),("operation
"):(.[6]),("key"):(.[7]),("request-uri"):(.[8]),("http-status-code"):(.[9]),("error-code"):(.[10]),("bytes-sent"):(.[11]),("object-size"):(.[12]),("total-time"):(.[13]),("turn-aroun
d-time"):(.[14]),("referer"):(.[15]),("user-agent"):(.[16]),("version-id"):(.[17]),("host-id"):(.[18]),("signature-version"):(.[19]),("cipher-suite"):(.[20]),("authentication-type")
:(.[21]),("host-header"):(.[22]),("tls-version"):(.[23]),("arn"):(.[24])}] | add' $s3file > $s3file.json
done
unset S3FILES
aws s3 rm s3://[$BUCKET_NAME]/[$FOLDER_NAME]/ --recursive --include="/*.*"" > s3accesslogs.sh
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
    <log_format>json</log_format>
    <location>/root/s3accesslogs/*.json</location>
</localfile>
```

## Configure Custom Rules

Add the following rules at the end of /var/ossec/etc/rules/local_rules.xml and restart the Wazuh Manager. 

```
<!--
ID: 100200 - 100299
-->

<group name="aws,s3">

    <rule id="100200" level="0">
        <decoded_as>json</decoded_as>
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
