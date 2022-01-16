#----------------
# Networking
#----------------
resource "hcloud_floating_ip" "kubeapi" {
  type          = var.kubeapi_ip_type
  home_location = local.datacenters[var.region][0]
  name          = "kubeapi-${var.cluster_name}"
  description   = "kubeapi IP for ${var.cluster_name} cluster"
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = hcloud_floating_ip.kubeapi.id
  server_id      = hcloud_server.master[0].id
}

resource "hcloud_firewall" "control_plane" {
  name = "control_plane-${var.cluster_name}"
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = var.master_node_template.ssh_port
    source_ips = var.ssh_source_ips
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = var.kubeapi_source_ips
  }

  apply_to {
    label_selector = "control_plane"
  }
}

resource "hcloud_server_network" "master" {
  count = var.master_node_count

  server_id = hcloud_server.master[count.index].id
  subnet_id = hcloud_network_subnet.cluster_subnet.id
}

#----------------
# Compute
#----------------
resource "hcloud_placement_group" "control_plane" {
  name = "control_plane-${var.cluster_name}"
  type = "spread"
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "random_shuffle" "control_plane_locations" {
  input        = local.datacenters[var.region]
  result_count = var.master_node_count
}

resource "hcloud_server" "master" {
  count = var.master_node_count

  name               = "${var.master_node_template.prefix}-${count.index}"
  image              = var.master_node_template.image
  server_type        = var.master_node_template.server_type
  location           = random_shuffle.control_plane_locations.result[count.index]
  placement_group_id = hcloud_placement_group.control_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = var.master_node_template.ssh_keys

  user_data = templatefile(
    "${path.module}/templates/control_plane_cloud-init.tmpl",
    {
      ci_user  = var.master_node_template.ci_user
      ssh_keys = var.master_node_template.ssh_keys
      ssh_port = var.master_node_template.ssh_port
    }
  )

  labels = merge({
    "managed-by"    = "terraform"
    "cluster-name"  = var.cluster_name
    "role"          = "master"
    "control_plane" = "true"
  }, var.common_labels)
}
