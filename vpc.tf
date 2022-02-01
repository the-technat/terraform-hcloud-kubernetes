resource "hcloud_network" "cluster_net" {
  name     = "cluster-network_${var.cluster_name}"
  ip_range = var.cluster_vpc_cidr
  labels = merge({
    "managed-by"   = "terraform"
    "service"      = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_network_subnet" "cluster_subnet" {
  network_id   = hcloud_network.cluster_net.id
  type         = "cloud"
  network_zone = var.region
  ip_range     = var.cluster_subnet_cidr
}
