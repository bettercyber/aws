The following bash script executes the following actions:
1. Creates a new subdirectory named $DATE in the sqlaudit directory, where $DATE is the current date.
2. Downloads new files from the specified AWS S3 bucket to the specified subdirectory. 
3. Removes the string *{"Items":[* from the beginning of the file.
4. Removes the string *]}* from the end of the file.
```
#!/bin/bash
aws s3 sync s3://bastionpod.rdslogs/ ~/sqlaudit --include "*.json"
sed -s -r 's/^\{\"Items\"\:\[//' ~/sqlaudit/*.json --in-place 
sed -s -r 's/\]\}$//' ~/sqlaudit/*.json --in-place
```
The following command makes the script executable.
```
chmod +x sqlaudit.sh
```
The following command executes the script
```
./sqlaudit.sh
```
## Running the Script in Wazuh
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
<localfile>
    <log_format>json</log_format>
    <location>/root/sqlaudit/*.json</location>
</localfile>
```
```
chown ossec sqlaudit
```
```
chmod u+w sqlaudit
```
