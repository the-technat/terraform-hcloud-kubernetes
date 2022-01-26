#----------------
# Networking
#----------------
resource "hcloud_floating_ip" "kubeapi" {
  type          = var.ip_mode
  home_location = var.master_nodes[0].location
  name          = "kubeapi-${var.cluster_name}"
  description   = "kubeapi IP for ${var.cluster_name} cluster"
  labels = merge({
    "managed-by"     = "terraform"
    "service"       = "k8s_at_hetzner"
    "cluster-name"   = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = hcloud_floating_ip.kubeapi.id
  server_id      = hcloud_server.master[0].id
}

resource "hcloud_firewall" "control_plane" {
  for_each = var.master_nodes

  name = each.value.name
  labels = merge({
    "managed-by"   = "terraform"
    "service"       = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels, each.value.labels)

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = each.value.ssh_port != 0 ? each.value.ssh_port : var.default_ssh_port
    source_ips = var.ssh_source_ips
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = var.kubeapi_source_ips
  }

  apply_to {
    server = hcloud_server.master[each.key].id
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
    "service"       = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_volume" "master" {
  for_each = var.master_nodes

  name      = each.value.name
  size      = each.value.size_gb
  server_id = hcloud_server.master[each.key].id
}

resource "hcloud_server" "master" {
  for_each = var.master_nodes

  name               = each.value.name
  server_type        = each.value.server_type
  image              = each.value.image
  location           = each.value.location
  placement_group_id = hcloud_placement_group.control_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = each.value.ssh_keys != [] ? each.value.ssh_keys : var.default_ssh_keys
  network {
    network_id = hcloud_network_subnet.cluster_subnet.id
  }

  user_data = templatefile(
    "${path.module}/templates/control_plane_cloud-init.tmpl",
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
    "role"          = "master"
    "control_plane" = "true"
  }, var.common_labels, each.value.labels)
}
