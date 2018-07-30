output "application_ipv4_address_private" {
  value = "${join(",",sort(digitalocean_droplet.application.*.ipv4_address_private))}"
}
