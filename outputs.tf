output "inventory" {
  value       = data.template_file.inventory.rendered
  description = "Ansible inventory file for kubespray"
}
