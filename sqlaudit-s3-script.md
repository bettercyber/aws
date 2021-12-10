# Monitoring AWS RDS Instance SQL Server Audit Logs with Wazuh

This document covers the following steps:

1. Create a bash script on the Wazuh manager to download and format the RDS instance logs from AWS S3. 
2. Configure Wazuh's command wodle to execute the script at a specified frequency.
3. Configure Wazuh to monitor and analyze the RDS instance log files. 
4. Configure Wazuh rules to alert on specific SQL server events.

## Configure the Bash Script

The following bash script executes the following actions:

1. Downloads new files from the specified AWS S3 bucket to the specified subdirectory. 
2. Removes the string *{"Items":[{* from the beginning of the file.
3. Replaces the string *{"event_time"* with *{"integration":"sqlaudit","event_time"*
4. Removes the string *]}* from the end of the file.
5. Replaces thes tring *},* with *}\n* to place each log in a separate line.

The following command creates a new file named sqlaudit.sh, copies the bash script to the new file, and makes the file executable. 
```
touch sqlaudit.sh
echo "#!/bin/bash
aws s3 sync s3://[$BUCKET_NAME]/ ~/sqlaudit --include "*.json"
sed -s -r 's/^\{\"Items\"\:\[//' ~/sqlaudit/*.json --in-place
sed -s -r 's/\{\"\event_time\"/\{\"integration\"\:\"sqlaudit\"\,\"event_time\"/g' ~/sqlaudit/*.json --in-place
sed -s -r 's/\]\}$//' ~/sqlaudit/*.json --in-place
sed -s -r 's/\}\,/\}\n/g' ~/sqlaudit/*.json --in-place" > sqlaudit.sh
chmod +x sqlaudit.sh
```
Run the following command to test the script:
```
./sqlaudit.sh
```

## Execute the Script in Wazuh

The command wodle will be used to execute the script every 10 minutes. Copy the following configuration in the /var/ossec/etc/ossec.conf file. The command assumes that the sqlaudit.sh script is in the root directory (/root/sqlaudit.sh). 
```
<wodle name="command">
    <disabled>no</disabled>
    <tag>sqlaudit-files</tag>
    <command>/bin/bash /root/sqlaudit.sh</command>
    <interval>10m</interval>
    <ignore_output>no</ignore_output>
    <run_on_start>yes</run_on_start>
    <timeout>0</timeout>
</wodle>
```

## Configure Wazuh to Read the RDS Audit Files

Add the following configuration to the /var/ossec/etc/ossec.conf file to monitor RDS SQL server audit logs. The command assumes that the RDS SQL audit files are in the /root/sqlaudit directory. 

```
<localfile>
    <log_format>json</log_format>
    <location>/root/sqlaudit/*.json</location>
</localfile>
```

## Configure Wazuh Rules to Detect SQL Server Events

Create a new CDB list named sqlaudit-events in /var/ossec/etc/lists. The CDB list will include all the SQL audit IDs for SQL server 2014.

```
cd /var/ossec/etc/lists
touch sqlaudit-events
echo "AS:ACCESS
APRL:ADD MEMBER
AL:ALTER
ALCN:ALTER CONNECTION
ALRS:ALTER RESOURCES
ALSS:ALTER SERVER STATE
ALST:ALTER SETTINGS
ALTR:ALTER TRACE
PWAR:APPLICATION_ROLE_CHANGE_PASSWORD_GROUP
AUSC:AUDIT SESSION CHANGED
AUSF:AUDIT SHUTDOWN ON FAILURE
CNAU:AUDIT_CHANGE_GROUP
AUTH:AUTHENTICATE
BA:BACKUP
BAL:BACKUP LOG
BRDB:BACKUP_RESTORE_GROUP
LGB:BROKER LOGIN
LGBG:BROKER_LOGIN_GROUP
ADBO:BULK ADMIN
LGDB:CHANGE DEFAULT DATABASE
LGLG:CHANGE DEFAULT LANGUAGE
CCLG:CHANGE LOGIN CREDENTIAL
PWCS:CHANGE OWN PASSWORD
PWC:CHANGE PASSWORD
USLG:CHANGE USERS LOGIN
USAF:CHANGE USERS LOGIN AUTO
CP:CHECKPOINT
CO:CONNECT
USTC:COPY PASSWORD
CR:CREATE
CMLG:CREDENTIAL MAP TO LOGIN
DBAF:DATABASE AUTHENTICATION FAILED
DBAS:DATABASE AUTHENTICATION SUCCEEDED
DBL:DATABASE LOGOUT
LGM:DATABASE MIRRORING LOGIN
MNDB:DATABASE_CHANGE_GROUP
DAGL:DATABASE_LOGOUT_GROUP
LGMG:DATABASE_MIRRORING_LOGIN_GROUP
ACDO:DATABASE_OBJECT_ACCESS_GROUP
MNDO:DATABASE_OBJECT_CHANGE_GROUP
TODO:DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP
GRDO:DATABASE_OBJECT_PERMISSION_CHANGE_GROUP
OPDB:DATABASE_OPERATION_GROUP
TODB:DATABASE_OWNERSHIP_CHANGE_GROUP
GRDB:DATABASE_PERMISSION_CHANGE_GROUP
MNDP:DATABASE_PRINCIPAL_CHANGE_GROUP
IMDP:DATABASE_PRINCIPAL_IMPERSONATION_GROUP
ADDP:DATABASE_ROLE_MEMBER_CHANGE_GROUP
DBCC:DBCC
DBCG:DBCC_GROUP
DL:DELETE
D:DENY
DWC:DENY WITH CASCADE
LGDA:DISABLE
DR:DROP
DPRL:DROP MEMBER
LGEA:ENABLE
EX:EXECUTE
XA:EXTERNAL ACCESS ASSEMBLY
DAGF:FAILED_DATABASE_AUTHENTICATION_GROUP
LGFL:FAILED_LOGIN_GROUP
FT:FULLTEXT
FTG:FULLTEXT_GROUP
G:GRANT
GWG:GRANT WITH GRANT
IMP:IMPERSONATE
IN:INSERT
LGIF:LOGIN FAILED
LGIS:LOGIN SUCCEEDED
PWCG:LOGIN_CHANGE_PASSWORD_GROUP
LGO:LOGOUT
LO:LOGOUT_GROUP
PWMC:MUST CHANGE PASSWORD
LGNM:NAME CHANGE
NMLG:NO CREDENTIAL MAP TO LOGIN
OP:OPEN
PWEX:PASSWORD EXPIRATION
PWPL:PASSWORD POLICY
RC:RECEIVE
RF:REFERENCES
PWRS:RESET OWN PASSWORD
PWR:RESET PASSWORD
RS:RESTORE
R:REVOKE
RWC:REVOKE WITH CASCADE
RWG:REVOKE WITH GRANT
ACO:SCHEMA_OBJECT_ACCESS_GROUP
MNO:SCHEMA_OBJECT_CHANGE_GROUP
TOO:SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP
GRO:SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP
SL:SELECT
SN:SEND
SVCN:SERVER CONTINUE
SVPD:SERVER PAUSED
SVSD:SERVER SHUTDOWN
SVSR:SERVER STARTED
MNSO:SERVER_OBJECT_CHANGE_GROUP
TOSO:SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP
GRSO:SERVER_OBJECT_PERMISSION_CHANGE_GROUP
OPSV:SERVER_OPERATION_GROUP
GRSV:SERVER_PERMISSION_CHANGE_GROUP
MNSP:SERVER_PRINCIPAL_CHANGE_GROUP
IMSP:SERVER_PRINCIPAL_IMPERSONATION_GROUP
ADSP:SERVER_ROLE_MEMBER_CHANGE_GROUP
STSV:SERVER_STATE_CHANGE_GROUP
SPLN:SHOW PLAN
SUQN:SUBSCRIBE QUERY NOTIFICATION
DAGS:SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP
LGSD:SUCCESSFUL_LOGIN_GROUP
TO:TAKE OWNERSHIP
C2OF:TRACE AUDIT C2OFF
C2ON:TRACE AUDIT C2ON
TASA:TRACE AUDIT START
TASP:TRACE AUDIT STOP
TRCG:TRACE_CHANGE_GROUP
TRO:TRANSFER
PWU:UNLOCK ACCOUNT
XU:UNSAFE ASSEMBLY
UP:UPDATE
UDAU:USER DEFINED AUDIT
UCGP:USER_CHANGE_PASSWORD_GROUP
UDAG:USER_DEFINED_AUDIT_GROUP
VWCT:VIEW CHANGETRACKING
VDST:VIEW DATABASE STATE
VSST:VIEW SERVER STATE" > sqlaudit-events
chown ossec sqlaudit-events 
chmod 660 sqlaudit-events 
chgrp ossec sqlaudit-events 
```
Add the new CBD list to /var/ossec/etc/ossec.conf:

```
<!-- User-defined ruleset -->
    <decoder_dir>etc/decoders</decoder_dir>
    <rule_dir>etc/rules</rule_dir>
<list>etc/lists/sqlaudit-events</list>
  </ruleset>
```

Create custom rules to detect SQL server events using the CDB list as a filter. Add the following rules to /var/ossec/etc/rules/local_rules.xml.
```
<!--
ID: 100100 - 100199
-->

<group name="sqlserver,aws">
    
    <!-- command wodle -->
    <rule id="100100" level="0">
        <decoded_as>json</decoded_as>
        <field name="integration">sqlaudit</field>
        <description>SQL server alert.</description>
        <options>no_full_log</options>
    </rule>
    
    <!-- Filter by eventName: etc/lists/sqlaudit-events -->
    <rule id="100101" level="3">
        <if_sid>100100</if_sid>
        <list field="action_id" lookup="match_key">etc/lists/sqlaudit-events</list>
        <description>SQL Server Event: $(statement).</description>
    </rule>
    
</group>
```


























































