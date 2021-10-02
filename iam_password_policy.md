## Set AWS IAM Password Policy

### Password Policy
The following command sets this password complexity policy:
* Minimum password length: 14
* Require uppercase letter: yes
* Require lowercase letter: yes
* Require number: yes
* Require special character: yes
* Password expiration: 90 days
* Administrator password reset required: no
* Allow users to change their passwords: yes
* Password history: 24

#### AWS CLI Command
```
update-account-password-policy /
--minimum-password-length 14 /
--require-symbols --require-numbers --require-uppercase-characters --require-lowercase-characters --allow-users-to-change-password /
--max-password-age 90 /
--password-reuse-prevention 24 /
--no-hard-expiry
