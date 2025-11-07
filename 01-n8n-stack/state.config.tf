terraform {
  backend "s3" {
    bucket       = "n8n-s3-remote-backend-bucket"
    key          = "n8n-stack/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}