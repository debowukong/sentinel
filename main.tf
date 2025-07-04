provider "aws" {
  region = "us-east-1"
}

resource "aws_resourcegroups_group" "test" {
  name = "test-group"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::EC2::Instance"
  ],
  "TagFilters": [
    {
      "Key": "Stage",
      "Values": ["Test"]
    }
  ]
}
JSON
  }

  tags = {
    Environment = "Test"
    Owner       = "YourName"
    Purpose     = "Demo group"
    # Add more tags as needed
  }
}
