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

resource "digitalocean_ssh_key" "ssh_key_bootstrap" {
  name       = "bootstrap"
  public_key = "${file("/data/keys/bootstrap.pub")}"
}

module "bastion" {
  source = "../../../modules/digital_ocean/bastion"

  env    = "${local.env}"
  region = "${local.region}"

  bastion_ssh_key                  = "${digitalocean_ssh_key.ssh_key_bootstrap.id}"
  bastion_droplet_size             = "${local.bastion_droplet_size}"
  bastion_droplet_image            = "${local.global_image}"
  loadbalance_ipv4_address_private = "${module.loadbalance.loadbalance_ipv4_address_private}"
  application_ipv4_address_private = "${module.application.application_ipv4_address_private}"
}

module "loadbalance" {
  source = "../../../modules/digital_ocean/loadbalance"

  env    = "${local.env}"
  region = "${local.region}"

  loadbalance_ssh_key          = "${digitalocean_ssh_key.ssh_key_bootstrap.id}"
  loadbalance_droplet_size     = "${local.loadbalance_droplet_size}"
  loadbalance_droplet_count    = "${local.loadbalance_droplet_count}"
  loadbalance_droplet_image    = "${local.global_image}"
  bastion_ipv4_address_private = "${module.bastion.bastion_ipv4_address_private}"
}

module "application" {
  source = "../../../modules/digital_ocean/application"

  env    = "${local.env}"
  region = "${local.region}"

  application_ssh_key              = "${digitalocean_ssh_key.ssh_key_bootstrap.id}"
  application_droplet_size         = "${local.application_droplet_size}"
  application_droplet_count        = "${local.application_droplet_count}"
  application_droplet_image        = "${local.global_image}"
  bastion_ipv4_address_private     = "${module.bastion.bastion_ipv4_address_private}"
  loadbalance_ipv4_address_private = "${module.loadbalance.loadbalance_ipv4_address_private}"
}
