from typing import Optional, Dict, Any

from dataclasses import dataclass


@dataclass(repr=False)
class AWSCredentials:
    aws_access_key_id: str
    aws_secret_access_key: str
    aws_session_token: Optional[str]

    @classmethod
    def from_temp_credentials(cls, creds: Dict[Any, Any]):
        credentials = creds.get("Credentials", {})
        # aws_access_key_id: str = credentials.get("AccessKeyId")
        # aws_secret_access_key: str = credentials.get("SecretAccessKey")
        # aws_session_token: str = credentials.get("SessionToken")

        return cls(
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials.get("SessionToken"),
        )
