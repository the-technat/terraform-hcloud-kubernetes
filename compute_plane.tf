#----------------
# Networking
#----------------
resource "hcloud_firewall" "compute_plane" {
  for_each = var.worker_nodes

  name = each.value.name
  labels = merge({
    "managed-by"     = "terraform"
    "service"       = "k8s_at_hetzner"
    "cluster-name"   = var.cluster_name
  }, var.common_labels)

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = each.value.ssh_port != 0 ? each.value.ssh_port : var.default_ssh_port
    source_ips = var.ssh_source_ips
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "30000-32767"
    source_ips = var.nodeport_source_ips
  }

  apply_to {
    server = hcloud_server.worker[each.key].id
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
    "service"       = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_volume" "worker" {
  for_each = var.worker_nodes

  name      = each.value.name
  size      = each.value.size_gb
  server_id = hcloud_server.worker[each.key].id
}

resource "hcloud_server" "worker" {
  for_each = var.worker_nodes

  name               = each.value.name
  server_type        = each.value.server_type
  image              = each.value.image
  location           = each.value.location
  placement_group_id = hcloud_placement_group.compute_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = each.value.ssh_keys != [] ? each.value.ssh_keys : var.default_ssh_keys
  network {
    network_id = hcloud_network_subnet.cluster_subnet.id
  }

  user_data = templatefile(
    "${path.module}/templates/compute_plane_cloud-init.tmpl",
    {
      ssh_user = each.value.ssh_user != "" ? each.value.ssh_user : var.default_ssh_user
      ssh_keys = each.value.ssh_keys != [] ? each.value.ssh_keys : var.default_ssh_keys
      ssh_port = each.value.ssh_port != 0 ? each.value.ssh_port : var.default_ssh_port
    }
  )

  labels = merge({
    "managed-by"    = "terraform"
    "service"       = "k8s_at_hetzner"
    "cluster-name"  = var.cluster_name
    "compute_plane" = "true"
  }, var.common_labels, each.value.labels)
}
