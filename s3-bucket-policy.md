# AWS S3 Bucket Policy

Deny interactive access to an S3 bucket for all users. 

### Bucket Policy

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Deny",
      "Resource": "arn:aws:s3:::[bucket-name]",
      "Principal": {
        "AWS": [
          "arn:aws:iam::[account_no]:user/*"
        ]
      }
    }
  ]
}
```
