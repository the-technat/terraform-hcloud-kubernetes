locals {
  master_ips_v4       = formatlist("%s/32", hcloud_server.master[*].ipv4_address)
  worker_ips_v4       = formatlist("%s/32", hcloud_server.worker[*].ipv4_address)
  master_ips_v6       = formatlist("%s", hcloud_server.master[*].ipv4_address)
  worker_ips_v6       = formatlist("%s", hcloud_server.worker[*].ipv6_address)
  master_templatefile = var.bootstrap_nodes == true ? "${path.module}/templates/control_plane_cloud-init-bootstrap.tmpl" : "${path.module}/templates/control_plane_cloud-init.tmpl"
  worker_templatefile = var.bootstrap_nodes == true ? "${path.module}/templates/compute_plane_cloud-init-bootstrap.tmpl" : "${path.module}/templates/compute_plane_cloud-init.tmpl"
}
