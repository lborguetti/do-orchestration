resource "digitalocean_tag" "loadbalance" {
  name = "${var.env}-loadbalance"
}

resource "digitalocean_droplet" "loadbalance" {
  image    = "${var.loadbalance_droplet_image}"
  name     = "${var.env}-loadbalance-${count.index}"
  count    = "${var.loadbalance_droplet_count}"
  region   = "${var.region}"
  size     = "${var.loadbalance_droplet_size}"
  ssh_keys = ["${var.loadbalance_ssh_key}"]
  tags     = ["${digitalocean_tag.loadbalance.id}"]

  private_networking = true
}

resource "digitalocean_firewall" "loadbalance" {
  name = "${var.env}-loadbalance"

  droplet_ids = ["${digitalocean_droplet.loadbalance.*.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
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
