resource "aws_cloudwatch_log_group" "example" {
  name              = "example"
  retention_in_days = 14
}

resource "aws_glue_job" "example" {
  # ... other configuration ...

  default_arguments = {
    # CloudWatch logging configuration
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.example.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    
    # Resource allocation configuration
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--TempDir"                          = "s3://aws-glue-temporary-{account-id}/temporary/"
    
    # Performance tuning
    "--enable-glue-datacatalog"          = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://aws-glue-assets-{account-id}/sparkHistoryLogs/"
    "--enable-job-insights"              = "true"
    "--enable-auto-scaling"              = "true"
    
    # Worker configuration
    "--number-of-workers"                = "5"
    "--worker-type"                      = "G.1X"
    "--max-capacity"                     = "10"
    "--max-retries"                      = "3"
    "--timeout"                          = "2880"  # 48 hours in minutes
    
    # Additional parameters
    "--conf"                             = "spark.sql.sources.partitionOverwriteMode=dynamic"
    "--datalake-formats"                 = "hudi,delta,iceberg"
    "--additional-python-modules"        = "boto3==1.24.91,pandas==1.5.3"
    "--extra-py-files"                   = "s3://bucket-name/path/to/additional/python/modules.zip"
    "--extra-jars"                       = "s3://bucket-name/path/to/additional/jars.jar"
  }
}