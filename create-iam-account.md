# Create an IAM User Account

1. Search IAM in the AWS search bar. 
2. Go to IAM and select Users under Access Management (left menu)
3. Add a New User:
   * Type in the user name
   * Under "Select AWS access type", check the following:
      * Access Key - Programmatic Access (if the developer needs access to AWS' APIs, which most of them do)
      * Password - AWS Management Console (if the developer needs access to the AWS console)
   * If the "Password - AWS Management Console" box is checked, set an account passsword or autogenerate one, and check "Require password reset".
   * Assign the user account to a user group:  
      * If the developer needs admin access to all AWS resources, then assign the new user account to the Administrators group.
      * If the developer needs read-only access to all AWS resources, then assign the new user account to the Auditors group.
      * If the developer needs access to Amplify, then assign the new user account to the DeveloperL1 group.
