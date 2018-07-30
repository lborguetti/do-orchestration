output "loadbalance_ipv4_address_private" {
  value = "${join(",",sort(digitalocean_droplet.loadbalance.*.ipv4_address_private))}"
}
