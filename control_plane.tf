#----------------
# Networking
#----------------
resource "hcloud_floating_ip" "kubeapi" {
  type          = var.ip_mode
  home_location = var.master_nodes[0].location
  name          = "kubeapi-${var.cluster_name}"
  description   = "kubeapi IP for ${var.cluster_name} cluster"
  labels = merge({
    "managed-by"   = "terraform"
    "service"      = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = hcloud_floating_ip.kubeapi.id
  server_id      = hcloud_server.master[0].id
}

resource "hcloud_firewall" "control_plane" {
  count = length(var.master_nodes)

  name = var.master_nodes[count.index].name
  labels = merge({
    "managed-by"   = "terraform"
    "service"      = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels, var.master_nodes[count.index].labels)

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = var.master_nodes[count.index].ssh_port != 0 ? var.master_nodes[count.index].ssh_port : var.default_ssh_port
    source_ips = var.ssh_source_ips
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = var.kubeapi_source_ips
  }

  apply_to {
    server = hcloud_server.master[count.index].id
  }
}

#----------------
# Compute
#----------------
resource "hcloud_placement_group" "control_plane" {
  name = "control_plane-${var.cluster_name}"
  type = "spread"
  labels = merge({
    "managed-by"   = "terraform"
    "service"      = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_volume" "master" {
  count = length(local.master_volumes)

  name      = local.master_volumes[count.index].name
  size      = local.master_volumes[count.index].size
  server_id = local.master_volumes[count.index].server_id

  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)

}

resource "hcloud_server" "master" {
  count = length(var.master_nodes)

  name               = var.master_nodes[count.index].name
  server_type        = var.master_nodes[count.index].server_type
  image              = var.master_nodes[count.index].image
  location           = var.master_nodes[count.index].location
  placement_group_id = hcloud_placement_group.control_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = var.master_nodes[count.index].ssh_keys != [] ? var.master_nodes[count.index].ssh_keys : var.default_ssh_keys
  network {
    network_id = hcloud_network.cluster_net.id
  }

  user_data = templatefile(
    "${path.module}/templates/control_plane_cloud-init.tmpl",
    {
      ssh_user = var.master_nodes[count.index].ssh_user != "" ? var.master_nodes[count.index].ssh_user : var.default_ssh_user
      ssh_keys = var.master_nodes[count.index].ssh_keys != [] ? var.master_nodes[count.index].ssh_keys : var.default_ssh_keys
      ssh_port = var.master_nodes[count.index].ssh_port != 0 ? var.master_nodes[count.index].ssh_port : var.default_ssh_port
    }
  )

  labels = merge({
    "managed-by"    = "terraform"
    "service"       = "k8s_at_hetzner"
    "cluster-name"  = var.cluster_name
    "role"          = "master"
    "control_plane" = "true"
  }, var.common_labels, var.master_nodes[count.index].labels)

  depends_on = [hcloud_network_subnet.cluster_subnet]
}
