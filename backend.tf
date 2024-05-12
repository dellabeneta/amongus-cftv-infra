terraform {
  backend "s3" {
    bucket = "tfstates.dellabeneta.online"
    key    = "amongus.dellabeneta.online/terraform.tfstate"
    region = "us-east-1"
  }
}