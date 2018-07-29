variable "env" {
  description = "environment to orchestrate"
}

variable "region" {
  description = "region where the resources should exist"
}

variable "bastion_droplet_size" {
  description = "instance size to bastion droplet"
}

variable "bastion_ssh_key" {
  description = "public ssh key to bastion droplet"
}

variable "bastion_droplet_image" {
  description = "image to bastion droplet"
}

variable "loadbalance_ipv4_address_private" {
  description = "droplet private networking IPv4 address"
}

variable "application_ipv4_address_private" {
  description = "droplet private networking IPv4 address"
}
