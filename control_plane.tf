#----------------
# Networking
#----------------

# floating_ip
resource "hcloud_floating_ip" "kubeapi" {
  count         = var.kubeapi_ha_type == "floating_ip" ? 1 : 0
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
  count         = var.kubeapi_ha_type == "floating_ip" ? 1 : 0
  floating_ip_id = hcloud_floating_ip.kubeapi[0].id
  server_id      = hcloud_server.master[0].id
}

# load_balancer
resource "hcloud_load_balancer" "kubeapi" {
  count              = var.kubeapi_ha_type == "load_balancer" ? 1 : 0
  name               = "kubeapi-${var.cluster_name}"
  load_balancer_type = "lb11"
  location           = var.master_nodes[0].location
  labels = merge({
    "managed-by"   = "terraform"
    "service"      = "k8s_at_hetzner"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_load_balancer_target" "kubeapi_lb_target" {
  count              = var.kubeapi_ha_type == "load_balancer" ? 1 : 0
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.kubeapi[0].id
  label_selector   = "control_plane=true"
}

resource "hcloud_load_balancer_service" "kubeapi_lb_service" {
  count              = var.kubeapi_ha_type == "load_balancer" ? 1 : 0
  load_balancer_id = hcloud_load_balancer.kubeapi[0].id
  protocol         = "tcp"
  listen_port      = "6443"
  destination_port = "6443"
}

# dns
data "hetznerdns_zone" "dns_zone" {
    name = "${var.cluster_name}"
}

resource "hetznerdns_record" "kubeapi" {
  count     = var.kubeapi_ha_type == "dns" ? length(var.master_nodes) : 0
  zone_id   = data.hetznerdns_zone.dns_zone.id
  name      = "kubeapi"
  value     = hcloud_server.master[count.index].ipv4_address
  type      = "A"
  ttl       = 60
  depends_on = [
    hcloud_server.master
  ]
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
    port       = var.ssh_port
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
    "service"      = "k8s_at_hetzner"
  }, var.common_labels, local.master_volumes[count.index].labels)
}

resource "hcloud_server" "master" {
  count = length(var.master_nodes)

  name               = var.master_nodes[count.index].name
  server_type        = var.master_nodes[count.index].server_type
  image              = var.master_nodes[count.index].image
  location           = var.master_nodes[count.index].location
  placement_group_id = hcloud_placement_group.control_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = hcloud_ssh_key.ssh_key[*].id
  network {
    network_id = hcloud_network.cluster_net.id
  }

  user_data = var.master_nodes[count.index].user_data != "" ? var.master_nodes[count.index].user_data : templatefile(
    "${path.module}/templates/control_plane_cloud-init.tmpl",
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
    "role"          = "master"
    "control_plane" = "true"
  }, var.common_labels, var.master_nodes[count.index].labels)

  depends_on = [hcloud_network_subnet.cluster_subnet, hcloud_ssh_key.ssh_key]
}
