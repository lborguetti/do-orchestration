resource "digitalocean_tag" "bastion" {
  name = "${var.env}-bastion"
}

resource "digitalocean_droplet" "bastion" {
  image    = "${var.bastion_droplet_image}"
  name     = "${var.env}-bastion"
  region   = "${var.region}"
  size     = "${var.bastion_droplet_size}"
  ssh_keys = ["${var.bastion_ssh_key}"]
  tags     = ["${digitalocean_tag.bastion.id}"]

  private_networking = true
}

resource "digitalocean_firewall" "bastion" {
  name = "${var.env}-bastion"

  droplet_ids = ["${digitalocean_droplet.bastion.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "udp"
      port_range            = "53"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "tcp"
      port_range            = "22"
      destination_addresses = ["${split(",",var.loadbalance_ipv4_address_private)}"]
    },
    {
      protocol              = "tcp"
      port_range            = "22"
      destination_addresses = ["${split(",",var.application_ipv4_address_private)}"]
    },
  ]
}
