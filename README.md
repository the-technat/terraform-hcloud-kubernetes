# terraform-hcloud-kubernetes

[![pipeline status](https://code.immerda.ch/k8s_at_hetzner/terraform-hcloud-kubernetes/badges/develop/pipeline.svg)](https://code.immerda.ch/k8s_at_hetzner/terraform-hcloud-kubernetes/-/commits/develop) 

Terraform Module to deploy the Infrastructure required for a Kubernetes Cluster at Hetzner Cloud

## Design Principles

As the [Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest) provider states it's best practise to apply K8S clusters and their addons in separate Terraform runs if you intend to deploy k8s addons using Terraform to avoid circular dependencies (Yes that's possible and a nightmare to fix, trust me...). Therefore this module only uses the [hcloud](https://registry.terraform.io/providers/hetznercloud/hcloud/latest) provider to provision the infrastructure for a Kubernetes cluster. The cluster itself shall be bootstraped using kubeadm or [kubespray](https://github.com/kubernetes-sigs/kubespray) as we think that [provisioners](https://www.terraform.io/language/resources/provisioners/syntax) are not really maintainable in the long run. Addons must be deployed separately. A solution for this will be published in the [k8s_at_hetzner](https://code.immerda.ch/k8s_at_hetzner) group.  

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
| [hcloud_locations.datacenters](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/locations) | data source |
| [hcloud_server_types.instance_types](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/server_types) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Common map of labels to add on all resources | `map(string)` | `{}` | no |
| <a name="input_control_plane_node_count"></a> [control\_plane\_node\_count](#input\_control\_plane\_node\_count) | How many master nodes do you want? | `number` | `3` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->