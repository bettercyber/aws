# Create an IAM User Account

1. Log in to the AWS Console and type _IAM_ in the search bar

![image](https://user-images.githubusercontent.com/78450870/144706096-93034afc-8db7-47d5-9a89-e8387e0c1784.png)

3. Go to **IAM** and select **Users** under _Access Management_
4. Add a New User:
   * Type in the user name
   * Under "Select AWS access type", check the following:
      * Access Key - Programmatic Access (if the developer needs access to AWS' APIs, which most of them do)
      * Password - AWS Management Console (if the developer needs access to the AWS console)
   * If the "Password - AWS Management Console" box is checked, set an account passsword or autogenerate one, and check "Require password reset".
   * Assign the user account to a user group:  
      * If the developer needs admin access to all AWS resources, then assign the new user account to the Administrators group.
      * If the developer needs read-only access to all AWS resources, then assign the new user account to the Auditors group.
      * If the developer needs access to Amplify, then assign the new user account to the DeveloperL1 group.
