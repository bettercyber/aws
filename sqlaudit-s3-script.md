```
#!/bin/bash
export YEAR=$(date +%Y)
export MONTH=$(date +%b)
export DAY=$(date +%d)
cd ~/sqlaudit
mkdir $YEAR-$MONTH-$DAY && cd ~/sqlaudit/$YEAR-$MONTH-$DAY
aws s3 sync s3://[$BUCKETNAME]/ ~/sqlaudit/$YEAR-$MONTH-$DAY --include "*.json"
sed -s -r 's/^\{\"Items\"\:\[//' *.json --in-place 
sed -s -r 's/\]\}$//' *.json --in-place
```
```
chmod +x sqlaudit.sh
```
```
./sqlaudit.sh
```
