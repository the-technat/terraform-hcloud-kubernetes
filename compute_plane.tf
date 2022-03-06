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
    port       = var.ssh_port
    source_ips = var.ssh_source_ips
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "30000-32767"
    source_ips = var.nodeport_source_ips
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
    "service"      = "k8s_at_hetzner"
  }, var.common_labels, local.worker_volumes[count.index].labels)
}

resource "hcloud_server" "worker" {
  count = length(var.worker_nodes)

  name               = var.worker_nodes[count.index].name
  server_type        = var.worker_nodes[count.index].server_type
  image              = var.worker_nodes[count.index].image
  location           = var.worker_nodes[count.index].location
  placement_group_id = hcloud_placement_group.compute_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = hcloud_ssh_key.ssh_key[*].id
  network {
    network_id = hcloud_network.cluster_net.id
  }

  user_data = var.worker_nodes[count.index].user_data != "" ? var.worker_nodes[count.index].user_data : templatefile(
    "${path.module}/templates/compute_plane_cloud-init.tmpl",
    {
      ssh_user = var.ssh_user
      ssh_keys = var.ssh_keys
      ssh_port = var.ssh_port
    }
  )

  labels = merge({
    "managed-by"    = "terraform"
    "service"       = "k8s_at_hetzner"
    "cluster-name"  = var.cluster_name
    "compute_plane" = "true"
    "role"          = "worker"
  }, var.common_labels, var.worker_nodes[count.index].labels)

  depends_on = [hcloud_network_subnet.cluster_subnet, hcloud_ssh_key.ssh_key]
}
