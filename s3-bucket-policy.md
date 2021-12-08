# AWS S3 Bucket Policy

The bucket policy described in this document restricts access to S3 to a specific IAM role. 

### IAM Role

The role specified in the bucket policy allows S3 read-only access to the EC2 service:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
    ]
}
```

### Bucket Policy
The bucket policy performs the following actions on the specified S3 bucket (*$BUCKETNAME*):
* Denies all S3 actions for all IAM users
* Allows all S3 actions for the specified IAM role (*$ROLEID*)

The *$ROLEID* can be obtained by executing the following command:

aws iam get-role --role-name *$ROLEID*
```
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17", 
            "Statement": [
                {
                    "Action": "sts:AssumeRole", 
                    "Effect": "Allow", 
                    "Principal": {
                        "Service": "ec2.amazonaws.com"
                    }
                }
            ]
        }, 
        "RoleId": "AROAXXXXXXXXXXXXX", 
        "CreateDate": "2021-12-08T11:12:19Z", 
        "RoleName": "ec2s3readonly", 
        "Path": "/", 
        "Arn": "arn:aws:iam::XXXXXXXXXX:role/ec2s3readonly"
    }
}
```
The bucket policy below is applied to the bucket named $BUCKETNAME under the Permissions tab.

#### Bucket Policy
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action":"s3:*",
      "Resource": "arn:aws:s3:::$BUCKETNAME",
      "Condition": {
        "StringNotLike": {"aws:userId": ["$ROLEID:*"]}
        }
    }
  ]
}
```

![image](https://user-images.githubusercontent.com/78450870/145206300-f2117de5-13df-452b-acdc-c05bbffd1e24.png)


