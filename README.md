# aws-tools

## Authenticating AWS CLI
A successful authentication may be required for most commands to run
```
$ sh aws-mfa.sh 123456 # MFA token
```

## Pull an ECR image
```
$ PASSWORD=$(aws ecr get-login-password --profile mfa)
$ docker login -u AWS -p $PASSWORD
$ docker pull <AWS_ECR_IMAGE_LINK>
```
