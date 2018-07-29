output "application_ipv4_address_private" {
  value = "${join(",",digitalocean_droplet.application.*.ipv4_address_private)}"
}
