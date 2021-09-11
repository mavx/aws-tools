from setuptools import setup, find_packages

with open("README.md", "r") as f:
    long_description = f.read()

setup(
    name="awstools",
    url="https://github.com/mavx/aws-tools",
    author="mavx",
    # Needed to actually package something
    packages=find_packages(exclude=["test*", "example*"]),
    package_data={"awstools": ["py.typed"]},
    version="0.0.1",
    description="AWS Tools",
    # We will also need a readme eventually (there will be a warning)
    long_description=long_description,
    python_requires="~=3.6",
    # Needed for dependencies
    install_requires=[
        "boto3~=1.17",
        "boto3-stubs[sts]~=1.17",
        "pytz~=2021.1",
        "dataclasses",
    ],
    extras_require={
        # Installable via pip install -e '.[dev]'
        "dev": [
            "black~=21.5b2",
        ],
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
)
