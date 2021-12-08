# S3 Bucket Server Access Logging

Enable S3 bucket server access logging as follows:

1. Log in to the AWS Console, navigate to S3, and select **Buckets**

![image](https://user-images.githubusercontent.com/78450870/145221880-00120195-1c5c-4030-9e14-a77867e36cbe.png)

2. Select the bucket for which logging needs to be enabled and navigate to the **Properties** tab

![image](https://user-images.githubusercontent.com/78450870/145222061-f98b873b-8189-46c8-956f-a411aa60779e.png)

3. Scroll down to **Server access logging** and click **Edit**

![image](https://user-images.githubusercontent.com/78450870/145222188-946007d7-4817-4dca-bd8d-fdbd7e6e1826.png)

4. Select **Enable**, enter the name of the S3 bucket where the S3 server access logs will be stored, and click **Save changes**

![image](https://user-images.githubusercontent.com/78450870/145222363-f3d892cd-aacc-4a6a-9150-500c8a7946b4.png)

5. S3 server access logs can now be viewed in CloudTrail

![image](https://user-images.githubusercontent.com/78450870/145223163-e886b01a-e619-4fa1-ac29-b66f99218ea4.png)
