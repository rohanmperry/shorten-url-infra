data "terraform_remote_state" "app" {
  backend = "s3"
  config = {
    bucket = "my-projects-tfstate"
    key    = "shorten-url-app/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "manual" {
  backend = "s3"
  config = {
    bucket = "my-projects-tfstate"
    key    = "shorten-url-infra-manual/terraform.tfstate"
    region = "us-east-1"
  }
}
