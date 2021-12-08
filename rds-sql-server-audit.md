# AWS RDS SQL Server Audit Logs

Follow these steps to enable SQL server auditing for an RDS instance:

1. Log in to the AWS Console, navigate to RDS, and select **Option groups**

![image](https://user-images.githubusercontent.com/78450870/145225792-73b13c47-52dd-447b-ada4-6656ce9590cc.png)

2. Select **Create group**. Alternatively, use an existing option group to set up SQL server auditing.

![image](https://user-images.githubusercontent.com/78450870/145225948-fc54ad18-0889-49f0-b62b-e81592237e30.png)

3. Enter the group name, description, database engine type and major version, and select **Create**

![image](https://user-images.githubusercontent.com/78450870/145226250-a0580b43-dc47-4f2b-97c5-daad0f7818a5.png)

4. Select the option group created in step 3, scroll down to **Options**, and select **Add option**

![image](https://user-images.githubusercontent.com/78450870/145226498-b479ce17-ac35-4e9b-95af-35bbc2695259.png)

![image](https://user-images.githubusercontent.com/78450870/145226620-8bf46bda-b23b-4210-a881-c12979852d3a.png)

5. Under *Option name* in the *Option details* section, select **SQLSERVER_AUDIT** from the drop-down menu

![image](https://user-images.githubusercontent.com/78450870/145226845-eeda28d5-440d-4e0b-826c-050f1f998d4e.png)

6. Select the S3 bucket where RDS audit logs will be stored and optionally enter a bucket prefix

![image](https://user-images.githubusercontent.com/78450870/145227061-fe9b7613-7efa-4322-b527-41f163395c73.png)

7. Select the IAM role that will execute the audit logging task

![image](https://user-images.githubusercontent.com/78450870/145227311-1cb44450-eb54-490c-9278-79b72680aafb.png)

8. Under *Scheduling*, select **Immediately** and then **Add option**

![image](https://user-images.githubusercontent.com/78450870/145227482-0f85318c-0891-4152-b15e-7f505dd10fce.png)


