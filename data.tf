locals {
  datacenters = { eu-central = ["hel1", "fsn1", "nbg1"], us-east = ["ash"] }
}


data "hcloud_locations" "datacenters" {}

data "hcloud_server_types" "instance_types" {}
