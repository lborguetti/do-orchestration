variable "env" {
  description = "environment to orchestrate"
}

variable "region" {
  description = "region where the resources should exist"
}

variable "application_droplet_size" {
  description = "instance size to application droplet"
}

variable "application_droplet_count" {
  description = "instance count to application droplet"
}

variable "application_ssh_key" {
  description = "public ssh key to application droplet"
}

variable "application_droplet_image" {
  description = "image to application droplet"
}

variable "bastion_ipv4_address_private" {
  description = "droplet private networking IPv4 address"
}

variable "loadbalance_ipv4_address_private" {
  description = "droplet private networking IPv4 address"
}
