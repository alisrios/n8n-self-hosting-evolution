variable "auth" {
  type = object({
    region          = string
    assume_role_arn = string
  })

  default = {
    assume_role_arn = "arn:aws:iam::148761658767:role/TerraformAssumeRole"
    region          = "us-east-1"
  }
}

variable "remote_backend" {
  type = object({
    s3_bucket = string
  })

  default = {
    s3_bucket = "n8n-s3-remote-backend-bucket"
  }
}

variable "tags" {
  type = map(string)

  default = {
    Environment = "production"
    Project     = "n8n-self-hosting-evolution"
  }

}