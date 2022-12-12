[![Wordpress CI](https://github.com/garutilorenzo/k8s-db-backup/actions/workflows/ci.yml/badge.svg)](https://github.com/garutilorenzo/k8s-db-backup/actions/workflows/ci.yml)
[![GitHub issues](https://img.shields.io/github/issues/garutilorenzo/k8s-db-backup)](https://github.com/garutilorenzo/k8s-db-backup/issues)
![GitHub](https://img.shields.io/github/license/garutilorenzo/k8s-db-backup)
[![GitHub forks](https://img.shields.io/github/forks/garutilorenzo/k8s-db-backup)](https://github.com/garutilorenzo/k8s-db-backup/network)
[![GitHub stars](https://img.shields.io/github/stars/garutilorenzo/k8s-db-backup)](https://github.com/garutilorenzo/k8s-db-backup/stargazers)

# K8s db backup

Containerized backup agent for MySQL with AWS and OCI S3 bucket support.
This container can be used to automatically create a logical backup of databases 
and store them on S3 object storage compatible provider.
Supported providers are: aws and oci

## Requirements

The only requirements is to have enough free space on your kubernetes worker/docker swarm node/docker node to store the logical backup
before it is transferred to the object storage.

## Supported environment variables

| Var   | Required | Desc |
| ------- | ------- | ----------- |
| `S3_PROVIDER`       | `yes`       | S3 compatible provider. Supported providers: aws, oci  |
| `AWS_SECRET_KEY`       | `yes if provider == 'aws'`       | aws secret key  |
| `AWS_ACCESS_KEY`       | `yes if provider == 'aws'`       | aws access key  |
| `AWS_REGION`       | `yes if provider == 'aws'`       | aws region  |
| `AWS_BUCKET_NAME`       | `yes if provider == 'aws'`       | aws bucket name  |
| `OCI_SECRET_KEY`       | `yes if provider == 'oci'`       | oci secret key  |
| `OCI_ACCESS_KEY`       | `yes if provider == 'oci'`       | oci access key  |
| `OCI_REGION`       | `yes if provider == 'oci'`       | oci region  |
| `OCI_BUCKET_NAME`       | `yes if provider == 'oci'`       | oci bucket name  |
| `OCI_NAMESPACE`       | `yes if provider == 'oci'`       | oci namespace. Follow Understanding Object Storage Namespaces on [OCI provider setup](#oci-provider-setup)  |
| `BACKUP_PATH_PREFIX`       | `no`       | Local and remote prefix where the backups will be stored. Default: k8s-db-backup  |
| `BACKUP_STRATEGY`       | `no`       | Define the backup strategy: single dump or split backup by tables. Default: SINGLE_FILE_DUMP. Supported strategies are SINGLE_FILE_DUMP and SPLIT_BY_TABLE |

### AWS provider setup

To get the AWS secret and access key follow the links below:
* [Accessing AWS using your AWS credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html)
* [Managing access keys for IAM users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

### OCI provider setup

To get the ICI secret and access key follow the links below:
* [Managing User Credentials](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm#create-secret-key)
* [Understanding Object Storage Namespaces](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/understandingnamespaces.htm)