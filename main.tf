provider "aws" {
  region = "####"  # add region
}

# S3 Bucket
resource "aws_s3_bucket" "data_lake_bucket" {
  bucket        = "####"  # put name
  force_destroy = true  #delete objects when deleting the bucket

  tags = {
    Name        = "DataLakeBucket"
    Environment = "####"  #tag to represent the environment ("Dev", "Prod")
  }
}

# Enable versioning on the Data Lake bucket for object protection
resource "aws_s3_bucket_versioning" "data_lake_bucket_versioning" {
  bucket = aws_s3_bucket.data_lake_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# s3 bucket to store Athena Query Results
resource "aws_s3_bucket" "athena_results_bucket" {
  bucket        = "####"  # put unique name
  force_destroy = true   #delete objects when deleting the bucket

  tags = {
    Name        = "AthenaResultsBucket"
    Environment = "####"  # Tag to represent the environment ("Dev", "Prod")
  }
}

# Glue Catalog Database for organizing metadata
resource "aws_glue_catalog_database" "data_lake_db" {
  name = "####"  # Replace with the name of your Glue database (e.g., "my_datalake_db")

  parameters = {
    "classification" = "parquet"  # Set classification; adjust if different (e.g., CSV, JSON)
  }
}

# IAM Role for Glue Crawler to access S3
resource "aws_iam_role" "glue_role" {
  name = "####"  #give indicative name to iam role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

# Attach S3 read-only policy to Glue IAM Role
resource "aws_iam_role_policy_attachment" "glue_s3_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  # Attach S3 read-only access
}

# Attach Glue service role policy to IAM Role
resource "aws_iam_role_policy_attachment" "glue_service_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Glue Crawler to automatically catalog data from the S3 bucket
resource "aws_glue_crawler" "data_lake_crawler" {
  name          = "####"  # Replace with the name of the Glue crawler (e.g., "data-lake-crawler")
  database_name = aws_glue_catalog_database.data_lake_db.name
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake_bucket.bucket}"  # Path to the S3 bucket containing data
  }
}

# Athena Workgroup Configuration for executing queries
resource "aws_athena_workgroup" "athena_workgroup" {
  name = "####"  # Replace with the name of the Athena workgroup (e.g., "my-athena-workgroup")
  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results_bucket.bucket}/"  # Location to save query results
    }
  }
}


output "data_lake_bucket_name" {
  value       = aws_s3_bucket.data_lake_bucket.bucket
  description = "The S3 bucket for the data lake"
}

output "athena_results_bucket_name" {
  value       = aws_s3_bucket.athena_results_bucket.bucket
  description = "The S3 bucket for Athena query results"
}

output "glue_database_name" {
  value       = aws_glue_catalog_database.data_lake_db.name
  description = "The Glue catalog database name"
}
