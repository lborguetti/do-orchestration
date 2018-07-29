output "loadbalance_ipv4_address_private" {
  value = "${join(",",digitalocean_droplet.loadbalance.*.ipv4_address_private)}"
}
