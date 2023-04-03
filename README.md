# terraform-hcloud-kubernetes

Terraform Module to deploy the Infrastructure required for a public-net Kubernetes Cluster at Hetzner Cloud

## Design

This module only touches hcloud infrastructure and cloud-init. It will never bootstrap any cluster for you (except for the things done in cloud-init).

I'm simply not a fan of local/remote execs and provisioners in Terraform.

## Usage

The module is published on the official terraform registry: <https://registry.terraform.io/modules/alleaffengaffen/kubernetes/hcloud/latest>

An example repo how to call this module can be found [here](https://github.com/alleaffengaffen/cks_training/blob/main/00_lab_env/kubernetes.tf).

## To Do

A list of open ideas:

- [ ] Generate ansible kubespray inventory similar to [this one](https://github.com/kubernetes-sigs/kubespray/blob/master/contrib/terraform/hetzner/modules/kubernetes-cluster/templates/cloud-init.tmpl)

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
| [hcloud_firewall.data_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_floating_ip.kubeapi](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/floating_ip) | resource |
| [hcloud_floating_ip_assignment.main](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/floating_ip_assignment) | resource |
| [hcloud_placement_group.control_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_placement_group.data_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_server.master](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server.worker](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_ssh_key.default_ssh_keys](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [hcloud_volume.master](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume) | resource |
| [hcloud_volume.worker](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume) | resource |
| [hcloud_locations.datacenters](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/locations) | data source |
| [hcloud_server_types.instance_types](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/server_types) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_fw_rules_master"></a> [additional\_fw\_rules\_master](#input\_additional\_fw\_rules\_master) | Additional rules for master nodes | <pre>list(object({<br>    direction         = string<br>    protocol          = string<br>    port              = string<br>    inject_master_ips = bool<br>    inject_worker_ips = bool<br>    source_ips        = list(string)<br>    description       = string<br>  }))</pre> | `[]` | no |
| <a name="input_additional_fw_rules_worker"></a> [additional\_fw\_rules\_worker](#input\_additional\_fw\_rules\_worker) | Additional rules for worker nodes | <pre>list(object({<br>    direction         = string<br>    protocol          = string<br>    port              = string<br>    inject_master_ips = bool<br>    inject_worker_ips = bool<br>    source_ips        = list(string)<br>    description       = string<br>  }))</pre> | `[]` | no |
| <a name="input_bootstrap_nodes"></a> [bootstrap\_nodes](#input\_bootstrap\_nodes) | Whether cloud-init should install all required tools on the nodes or not | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | A cluster-name that is used to suffix every resource name | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Common map of labels to add on all resources | `map(string)` | `{}` | no |
| <a name="input_default_ssh_keys"></a> [default\_ssh\_keys](#input\_default\_ssh\_keys) | List of default (public) ssh keys to configure on the ssh\_user | `list(string)` | n/a | yes |
| <a name="input_default_ssh_port"></a> [default\_ssh\_port](#input\_default\_ssh\_port) | The default SSH Port configured and rechable on each machine | `number` | `22` | no |
| <a name="input_default_ssh_user"></a> [default\_ssh\_user](#input\_default\_ssh\_user) | Username of a default admin user created on every machine | `string` | `"ansible"` | no |
| <a name="input_enable_floating_kubeapi"></a> [enable\_floating\_kubeapi](#input\_enable\_floating\_kubeapi) | Whether a floating public IP for the kubeapi should be provisioned or not | `bool` | `false` | no |
| <a name="input_enable_private_networking"></a> [enable\_private\_networking](#input\_enable\_private\_networking) | Whether to deploy a private network or not | `bool` | `false` | no |
| <a name="input_enable_server_backups"></a> [enable\_server\_backups](#input\_enable\_server\_backups) | Whether to enable server backups in hcloud. | `bool` | `false` | no |
| <a name="input_ip_mode"></a> [ip\_mode](#input\_ip\_mode) | All in on IPv4 or IPv6? | `string` | `"ipv6"` | no |
| <a name="input_kubeapi_source_ips"></a> [kubeapi\_source\_ips](#input\_kubeapi\_source\_ips) | Limit the ips that are allowed to talk to our kubeapi. (Worker-nodes will always be allowed) | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_master_nodes"></a> [master\_nodes](#input\_master\_nodes) | List of master nodes to provision in the cluster, each master node has a set of values you can configure | <pre>list(object({<br>    name        = string<br>    server_type = string<br>    image       = string<br>    labels      = map(string)<br>    location    = string<br>    volumes = list(object({<br>      name    = string<br>      size_gb = number<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "image": "ubuntu-22.04",<br>    "labels": {},<br>    "location": "hel1",<br>    "name": "master-0",<br>    "server_type": "cpx11",<br>    "volumes": []<br>  }<br>]</pre> | no |
| <a name="input_nodeport_source_ips"></a> [nodeport\_source\_ips](#input\_nodeport\_source\_ips) | Who is allowed to connect to your nodeport services (e.g only a LoadBalancer...) | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | In which region should your cluster be? | `string` | n/a | yes |
| <a name="input_ssh_source_ips"></a> [ssh\_source\_ips](#input\_ssh\_source\_ips) | Limit the ips that are allowed to ssh into our cluster nodes. | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | List of worker nodes to provision in the cluster, each master node has a set of values you can configure | <pre>list(object({<br>    name        = string<br>    server_type = string<br>    image       = string<br>    labels      = map(string)<br>    location    = string<br>    volumes = list(object({<br>      name    = string<br>      size_gb = number<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "image": "ubuntu-22.04",<br>    "labels": {},<br>    "location": "nbg1",<br>    "name": "worker-0",<br>    "server_type": "cpx31",<br>    "volumes": []<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_master_ips"></a> [master\_ips](#output\_master\_ips) | n/a |
| <a name="output_worker_ips"></a> [worker\_ips](#output\_worker\_ips) | n/a |
<!-- END_TF_DOCS -->