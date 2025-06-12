terraform {
  backend "s3" {
    bucket         = "weather-forecast-tf-state"
    key            = "statefiles/github-runner/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "weather-forecast-tf-lock"
    encrypt        = true
  }
}
