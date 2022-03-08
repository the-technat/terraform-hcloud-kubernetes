terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "2.1.0"
    }
  }
}
