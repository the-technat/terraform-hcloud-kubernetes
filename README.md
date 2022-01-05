# terraform-hcloud-kubernetes

[![pipeline status](https://code.immerda.ch/k8s_at_hetzner/terraform-hcloud-kubernetes/badges/develop/pipeline.svg)](https://code.immerda.ch/k8s_at_hetzner/terraform-hcloud-kubernetes/-/commits/develop) 

Terraform Module to deploy the Infrastructure required for a Kubernetes Cluster at Hetzner Cloud

## Design Principles

As the [Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources) provider states it's best practise to apply K8S clusters and their addons in separate Terraform runs if you intend to deploy k8s addons using Terraform to avoid circular dependencies (Yes that's possible and a nightmare to fix, trust me...). Therefore this module only uses the [hcloud](https://registry.terraform.io/providers/hetznercloud/hcloud/latest) provider to provision the infrastructure for a Kubernetes cluster. The cluster itself shall be bootstraped using kubeadm or [kubespray](https://github.com/kubernetes-sigs/kubespray) as we think that [provisioners](https://www.terraform.io/language/resources/provisioners/syntax) are not really maintainable in the long run. Addons must be deployed separately. A solution for this will be published in the [k8s_at_hetzner](https://code.immerda.ch/k8s_at_hetzner) group.  

## Usage

An example repo how to call this module can be found [here](TODO: create example environment repo).

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.control_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_floating_ip.kubeapi](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/floating_ip) | resource |
| [hcloud_floating_ip_assignment.main](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/floating_ip_assignment) | resource |
| [hcloud_placement_group.control_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_server.master](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_locations.datacenters](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/locations) | data source |
| [hcloud_server_types.instance_types](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/server_types) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | A cluster-name that is used to suffix every resource name | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Common map of labels to add on all resources | `map(string)` | `{}` | no |
| <a name="input_enable_server_backups"></a> [enable\_server\_backups](#input\_enable\_server\_backups) | Wether to enable server backups in hcloud. | `bool` | `false` | no |
| <a name="input_kubeapi_ip_type"></a> [kubeapi\_ip\_type](#input\_kubeapi\_ip\_type) | Should your kubeapi be rechable on an IPv4 or IPv6 address? | `string` | `"ipv6"` | no |
| <a name="input_kubeapi_source_ips"></a> [kubeapi\_source\_ips](#input\_kubeapi\_source\_ips) | Limit the ips that are allowed to talk to our kubeapi. (Worker-nodes will always be allowed) | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_master_node_count"></a> [master\_node\_count](#input\_master\_node\_count) | How many master nodes do you want? | `number` | n/a | yes |
| <a name="input_master_node_template"></a> [master\_node\_template](#input\_master\_node\_template) | A template how a master node is provisioned | <pre>object({<br>    prefix = string <br>    server_type = string <br>    image = string<br>    ci_user = string<br>    ssh_keys = list(string)<br>    ssh_port = number<br>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | In which region should your cluster be? | `string` | n/a | yes |
| <a name="input_ssh_source_ips"></a> [ssh\_source\_ips](#input\_ssh\_source\_ips) | Limit the ips that are allowed to ssh into our cluster nodes. | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->