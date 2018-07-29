resource "digitalocean_tag" "application" {
  name = "${var.env}-application"
}

resource "digitalocean_droplet" "application" {
  image    = "${var.application_droplet_image}"
  name     = "${var.env}-application-${count.index}"
  count    = "${var.application_droplet_count}"
  region   = "${var.region}"
  size     = "${var.application_droplet_size}"
  ssh_keys = ["${var.application_ssh_key}"]
  tags     = ["${digitalocean_tag.application.id}"]

  monitoring         = true
  private_networking = true
}

resource "digitalocean_firewall" "application" {
  name = "${var.env}-application"

  droplet_ids = ["${digitalocean_droplet.application.*.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["${split(",",var.loadbalance_ipv4_address_private)}"]
    },
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["${var.bastion_ipv4_address_private}"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "udp"
      port_range            = "53"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}
