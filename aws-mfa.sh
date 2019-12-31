#!/bin/bash

# Default values
TOKEN="$1" # Accepts token without requiring -t flag
NAME="mfa"
AWS_PROFILE="default"
REGION=$(aws configure get region --profile $AWS_PROFILE)

# Parse options
while getopts t:n:p: option
do
case "${option}"
in
t) TOKEN=${OPTARG};;
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

ARN=$(aws sts get-caller-identity | jq --raw-output '.Arn' | sed 's/user/mfa/')
exit_if_error

echo -e "Using profile: $AWS_PROFILE"
echo "Region: $REGION"
echo "MFA profile: $NAME"
echo "ARN: $ARN"

CREDENTIALS=$(aws sts get-session-token --serial-number $ARN --token-code $TOKEN)
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
