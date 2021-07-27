#!/bin/bash

# Usage 1: 
# $ ./aws-mfa -r arn:aws:iam::xxx:role/CrossAccountRole  # <--- Your MFA token
# 
# Usage 2:
# $ ./aws-mfa -n mfa -p dev
# * -n: The AWS profile name to create for this MFA session
# * -p: The AWS profile that you wish to authenticate as
# & -r: The Role ARN to assume to

# Default values
ROLE_ARN="$1"
NAME="assume-role"
AWS_PROFILE="mfa"
REGION=$(aws configure get region --profile $AWS_PROFILE)

# Parse options
while getopts r:n:p: option
do
case "${option}"
in
r) ROLE_ARN=${OPTARG};;
n) NAME=${OPTARG};;
p) AWS_PROFILE=${OPTARG};;
esac
done

# Define status check for each test
exit_if_error() {
    local exit_code=$?
    if (( $exit_code )); then
        printf '\e[91mAborted!'
        exit 1
    fi
}

echo -e "Using profile: $AWS_PROFILE"
echo "Region: $REGION"
echo "AssumeRole profile: $NAME"
echo "AssumingRole: $ROLE_ARN"
# echo "ARN: $ARN"

CREDENTIALS=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name mauyong-cli --profile $AWS_PROFILE)
exit_if_error

ACCESS_KEY_ID=$(echo $CREDENTIALS | jq --raw-output '.Credentials.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq --raw-output '.Credentials.SecretAccessKey')
SESSION_TOKEN=$(echo $CREDENTIALS | jq --raw-output '.Credentials.SessionToken')
EXPIRATION=$(echo $CREDENTIALS | jq --raw-output '.Credentials.Expiration')
exit_if_error

aws configure set aws_access_key_id $ACCESS_KEY_ID --profile $NAME
aws configure set aws_secret_access_key $SECRET_ACCESS_KEY --profile $NAME
aws configure set aws_session_token $SESSION_TOKEN --profile $NAME
aws configure set region $REGION --profile $NAME

echo "> All set! Token will expire by $(tput bold)$EXPIRATION$(tput sgr0)"
echo "> Sample usage: aws s3 ls --profile $NAME"
