terraform{
  backend "s3" {
    bucket         = "terraformgithubbucket"
    key            = "NSH-fargate/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
