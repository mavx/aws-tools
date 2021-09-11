"""
This module accepts default credential inputs and extends it
to work with MFA and other assume-role functions
"""
from typing import Optional

import boto3
from getpass import getpass

from awstools.model import AWSCredentials
from mypy_boto3_sts import STSClient
from mypy_boto3_sts.type_defs import (
    GetCallerIdentityResponseTypeDef,
    GetSessionTokenResponseTypeDef,
    AssumeRoleResponseTypeDef,
)


def get_mfa() -> str:
    """
    Prompt user for MFA code from device
    :return: 6-digit code as `str`
    """
    usr_input: str = input("Type in MFA code: \n").strip().replace(" ", "")

    if len(usr_input) != 6 or not usr_input.isdigit():
        raise ValueError("Must be a 6-digit input!")

    return usr_input


def get_aws_session(
    reset: bool = False,
    prompt_credentials: bool = False,
) -> AWSCredentials:
    """
    Get the temporary session credentials either through a new
    session, or reusing existing session credentials if it's
    still valid
    :param reset: To force getting a new session
    :return:
    """
    if reset:
        raise NotImplementedError

    aws_access_key_id = getpass("AWS_ACCESS_KEY_ID: ") if prompt_credentials else None
    aws_secret_access_key = (
        getpass("AWS_SECRET_ACCESS_KEY: ") if prompt_credentials else None
    )

    client: STSClient = boto3.client(
        service_name="sts",
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
    )

    resp: GetCallerIdentityResponseTypeDef = client.get_caller_identity()
    arn: str = resp.get("Arn", "").replace(":user/", ":mfa/")
    print(arn)

    response: GetSessionTokenResponseTypeDef = client.get_session_token(
        SerialNumber=arn, TokenCode=get_mfa()
    )

    expiry = response["Credentials"]["Expiration"]
    print(f"AWS Token obtained with Expiration at: {expiry}")

    return AWSCredentials.from_temp_credentials(dict(response))


def assume_role(
    role_arn: str,
    aws_access_key_id: Optional[str] = None,
    aws_secret_access_key: Optional[str] = None,
    aws_session_token: Optional[str] = None,
) -> AssumeRoleResponseTypeDef:
    client: STSClient = boto3.client(
        service_name="sts",
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        aws_session_token=aws_session_token,
    )

    resp: AssumeRoleResponseTypeDef = client.assume_role(
        RoleArn=role_arn,
        RoleSessionName="aws-tools-authenticate.py",
    )

    return AWSCredentials.from_temp_credentials(dict(resp))
