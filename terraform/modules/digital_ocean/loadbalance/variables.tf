variable "env" {
  description = "environment to orchestrate"
}

variable "region" {
  description = "region where the resources should exist"
}

variable "loadbalance_droplet_size" {
  description = "instance size to loadbalance droplet"
}

variable "loadbalance_droplet_count" {
  description = "instance count to loadbalance droplet"
}

variable "loadbalance_ssh_key" {
  description = "public ssh key to loadbalance droplet"
}

variable "loadbalance_droplet_image" {
  description = "image to loadbalance droplet"
}

variable "bastion_ipv4_address_private" {
  description = "droplet private networking IPv4 address"
}
