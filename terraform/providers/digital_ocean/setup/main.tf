provider "digitalocean" {
  version = "0.1.3"
}

terraform {
  required_version = "0.11.7"

  backend "s3" {
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_metadata_api_check     = true
    endpoint                    = "https://nyc3.digitaloceanspaces.com"
    region                      = "us-east-1"
    bucket                      = "do-orchestration-state"
  }
}

resource "digitalocean_ssh_key" "bootstrap" {
  name       = "bootstrap"
  public_key = "${file("/data/keys/bootstrap.pub")}"
}
