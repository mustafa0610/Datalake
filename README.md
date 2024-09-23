# Data Lake
## Overview 
This project demonstrates the creation of a data lake using AWS services. 
## AWS Setup 
The data lake is set up using Terraform, which automates the creation of the following AWS resources: 
- S3 buckets for storing raw data and Athena query results- - AWS Glue Catalog database and crawlers for metadata management - Athena workgroup for querying data 

Run the following commands: ```bash terraform init terraform apply  

## Usage
To query the data in AWS Athena on Windows, use the following command:

```bash
aws athena start-query-execution `
  --query-string "SELECT * FROM my_datalake_db.my_datalake_bucket_unique_12345 LIMIT 10;" `
  --query-execution-context Database=my_datalake_db `
  --result-configuration OutputLocation=s3://my-athena-results-bucket-unique-12345/ `
  --region ap-southeast-2
