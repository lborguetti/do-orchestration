locals {
  env                    = "prod-nyc3-blue"
  region                 = "nyc3"

  global_image = "ubuntu-16-04-x32"

  bastion_droplet_size = "512mb"

  loadbalance_droplet_size  = "512mb"
  loadbalance_droplet_count = "2"

  application_droplet_size  = "512mb"
  application_droplet_count = "2"

}
