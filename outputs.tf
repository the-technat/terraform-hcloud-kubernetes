output "kubeapi_ip" {
  value = hcloud_floating_ip.kubeapi[0].ip_address
}

output "master_ips" {
  value = local.master_ips
}

output "worker_ips" {
  value = local.worker_ips
}
