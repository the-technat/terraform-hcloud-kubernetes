locals {
  datacenters = { eu-central = ["hel1", "fsn1", "nbg1"], us-east = ["ash"] }

  master_volumes = flatten([
    for server in var.master_nodes : [
      for volume_key, volume in server.volumes : {
        name      = volume.name
        size      = volume.size_gb
        server_id = hcloud_server.master[server.index].id
        labels    = hcloud_server.master[server.index].labels
      }
    ]
  ])
  worker_volumes = flatten([
    for server in var.worker_nodes : [
      for volume_key, volume in server.volumes : {
        name      = volume.name
        size      = volume.size_gb
        server_id = hcloud_server.worker[server.index].id
        labels    = hcloud_server.worker[server.index].labels
      }
    ]
  ])
}

data "hcloud_locations" "datacenters" {}

data "hcloud_server_types" "instance_types" {}

data "template_file" "inventory" {
  template = file("${path.module}/templates/inventory.tpl")

  vars = {
    connection_strings_master = join("\n", formatlist("%s ansible_user=%s ansible_host=%s ansible_port=%d", var.master_nodes[*].name, var.ssh_user, hcloud_server.master[*].ipv4_address, var.ssh_port))

    connection_strings_worker = join("\n", formatlist("%s ansible_user=%s ansible_host=%s ansible_port=%d", var.worker_nodes[*].name, var.ssh_user, hcloud_server.worker[*].ipv4_address, var.ssh_port))

  }

  depends_on = [
    hcloud_server.master,
    hcloud_server.worker
  ]

}

# resource "null_resource" "inventories" {
#   provisioner "local-exec" {
#     command = "echo '${data.template_file.inventory.rendered}' > ${var.inventory_file}"
#   }

#   triggers = {
#     template = data.template_file.inventory.rendered
#   }
# }
