output "bastion_ipv4_address_private" {
  value = "${digitalocean_droplet.bastion.ipv4_address_private}"
}
