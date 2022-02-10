resource "hcloud_ssh_key" "ssh_key" {
  count = length(var.ssh_keys)

  name       = "Terraform-managed ssh_key ${count.index}"
  public_key = var.ssh_keys[count.index]
}
