# Create an IAM User Account

1. Search IAM in the AWS search bar. 
2. Go to IAM and select Users under Access Management (left menu)
3. Add a New User:
   * Type in the user name
   * Under "Select AWS access type", check the following:
      * Access Key - Programmatic Access (if the developer needs access to AWS' APIs, which most of them do)
      * Password - AWS Management Console (if the developer needs access to the AWS console)
   * If the "Password - AWS Management Console" box is checked, set an account passsword or autogenerate one, and check "Require password reset".
   * Click Next until the account is created. You will then create a User Group with the required permissions and assign the new user account to the group.  
5. Select User Groups under Access Management (left menu)
6. If the developer needs admin access to all AWS resources, then assign the new user account to the Administrators group.
7. If the developer needs read-only access to all AWS resources, then assign the new user account to the Auditors group.
8. If the developer needs access to Amplify, then assign the new user account to the DeveloperL1 group.
