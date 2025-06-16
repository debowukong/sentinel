provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudtrail" "example" {
  # ... other configuration ...

  event_selector {
    read_write_type           = "All"
    include_management_events = true

  }
}
