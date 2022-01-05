#----------------
# Networking
#----------------
resource "hcloud_firewall" "compute_plane" {
  name = "worker_nodes-${var.cluster_name}"
  labels = merge({
    "managed-by" = "terraform"
    "cluster-name" = var.cluster_name
  },var.common_labels)

  rule {
   direction = "in"
   protocol = "tcp"
   port = var.worker_node_template.ssh_port
   source_ips = var.ssh_source_ips
  }

  rule {
   direction = "in"
   protocol = "tcp"
   port = "30000-32767"
   source_ips = var.nodeport_source_ips
  }

  apply_to {
    label_selector = "compute_plane" 
  }
}

resource "hcloud_server_network" "worker" {
  count = var.worker_node_count

  server_id = hcloud_server.worker[count.index].id 
  subnet_id = hcloud_network_subnet.cluster_subnet.id
}

#----------------
# Compute
#----------------
resource "hcloud_placement_group" "compute_plane" {
  name = "compute_plane-${var.cluster_name}"
  type = "spread"
  labels = merge({
    "managed-by" = "terraform"
    "cluster-name" = var.cluster_name
  },var.common_labels)
}

resource "hcloud_server" "worker" {
  count = var.worker_node_count

  name        = "${var.worker_node_template.prefix}-${count.index}"
  image       = var.worker_node_template.image
  server_type = var.worker_node_template.server_type 
  placement_group_id = hcloud_placement_group.compute_plane.id
  backups     = var.enable_server_backups
  location    = var.region
  # ssh_keys = var.worker_node_template.ssh_keys

  user_data = templatefile(
    "${path.module}/templates/compute_plane_cloud-init.tmpl",
    {
      ci_user = var.master_node_template.ci_user
      ssh_keys = var.master_node_template.ssh_keys
      ssh_port = var.master_node_template.ssh_port
    }
  )

  labels = merge({
    "managed-by" = "terraform"
    "cluster-name" = var.cluster_name
    "role" = "worker"
    "compute_plane" = "true"
  },var.common_labels) 
}