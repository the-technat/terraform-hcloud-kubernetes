output "kubeapi_ip" {
  value = hcloud_floating_ip.kubeapi.ip_address
}
