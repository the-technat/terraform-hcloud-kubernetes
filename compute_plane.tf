#----------------
# Networking
#----------------
resource "hcloud_firewall" "compute_plane" {
  count = length(var.worker_nodes)

  name = var.worker_nodes[count.index].name
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
    "service"      = "k8s_at_hetzner"
  }, var.common_labels, var.worker_nodes[count.index].labels)

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = var.default_ssh_port
    source_ips = var.ssh_source_ips
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "30000-32767"
    source_ips = var.nodeport_source_ips
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "10250"
    source_ips = var.ip_mode == "ipv4" ? local.master_ips_v4 : local.master_ips_v6
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "4240"
    source_ips = var.ip_mode == "ipv4" ? local.master_ips_v4 : local.master_ips_v6
  }
  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "8472"
    source_ips = var.ip_mode == "ipv4" ? local.master_ips_v4 : local.master_ips_v6
  }
  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "51871"
    source_ips = var.ip_mode == "ipv4" ? local.master_ips_v4 : local.master_ips_v6
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "4240"
    source_ips = var.ip_mode == "ipv4" ? local.worker_ips_v4 : local.worker_ips_v6
  }
  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "8472"
    source_ips = var.ip_mode == "ipv4" ? local.worker_ips_v4 : local.worker_ips_v6
  }
  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "51871"
    source_ips = var.ip_mode == "ipv4" ? local.worker_ips_v4 : local.worker_ips_v6
  }

  apply_to {
    server = hcloud_server.worker[count.index].id
  }
}

#----------------
# Compute
#----------------
resource "hcloud_placement_group" "compute_plane" {
  name = "compute_plane-${var.cluster_name}"
  type = "spread"
  labels = merge({
    "managed-by"   = "terraform"
    "service"      = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_volume" "worker" {
  count = length(local.worker_volumes)

  name      = local.worker_volumes[count.index].name
  size      = local.worker_volumes[count.index].size
  server_id = local.worker_volumes[count.index].server_id

  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)

}

resource "hcloud_server" "worker" {
  count = length(var.worker_nodes)

  name               = var.worker_nodes[count.index].name
  server_type        = var.worker_nodes[count.index].server_type
  image              = var.worker_nodes[count.index].image
  location           = var.worker_nodes[count.index].location
  placement_group_id = hcloud_placement_group.compute_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = hcloud_ssh_key.default_ssh_keys[*].id

  user_data = templatefile(
    local.worker_templatefile,
    {
      ssh_user = var.default_ssh_user
      ssh_keys = var.default_ssh_keys
      ssh_port = var.default_ssh_port
    }
  )

  public_net {
    ipv4_enabled = var.ip_mode == "ipv4" ? true : false
    ipv6_enabled = var.ip_mode == "ipv6" ? true : false
  }

  labels = merge({
    "managed-by"    = "terraform"
    "cluster-name"  = var.cluster_name
    "compute_plane" = "true"
  }, var.common_labels, var.worker_nodes[count.index].labels)

}
