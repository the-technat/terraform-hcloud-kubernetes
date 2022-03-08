#----------------
# General Vars
#----------------
variable "common_labels" {
  type        = map(string)
  default     = {}
  description = "Common map of labels to add on all resources"
}

variable "cluster_name" {
  type        = string
  description = "A cluster-name that is used to suffix every resource name"
}


#----------------
# Networking
#----------------
variable "network_region" {
  type        = string
  description = "In which network region should your cluster network be? (eu-central, us-east)"
  validation {
    condition     = can(regex("(eu-central|us-east)", var.network_region))
    error_message = "The network_region must be one of the following values: [eu-central, us-east]."
  }
}

variable "ip_mode" {
  type        = string
  default     = "ipv6"
  description = "Should all components talk to each other over IPv4 or IPv6? (IPv6 saves costs)"
  validation {
    condition     = can(regex("(ipv4|ipv6)", var.ip_mode))
    error_message = "The ip_mode must either by 'ipv4' or 'ipv6'."
  }
}

variable "kubeapi_ha_type" {
  type        = string
  default     = "load_balancer"
  description = "How should the kubeapi served HA (via load_balancer, floating_ip, dns or none)"
  validation {
    condition     = can(regex("(load_balancer|floating_ip|dns|none)", var.kubeapi_ha_type))
    error_message = "The ip_mode must either by 'load_balancer', 'floating_ip', 'dns' or 'none'."
  }
}

variable "cluster_vpc_cidr" {
  type        = string
  default     = "10.123.0.0/16"
  description = "A valid CIDR for the cluster network (multiple subnets within that network will be created)"
}

variable "cluster_subnet_cidr" {
  type        = string
  default     = "10.123.0.0/24"
  description = "A valid CIDR within the cluster_vpc_cidr for the cluster subnet"
}

variable "nodeport_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Who is allowed to connect to your nodeport services (e.g only a LoadBalancer...)?"
}

variable "ssh_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Limit the ips that are allowed to ssh into our cluster nodes."
}

variable "kubeapi_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Limit the ips that are allowed to talk to our kubeapi. (Worker-nodes will always be allowed)"
}

#----------------
# Toggle Vars
# Switch things on and off
#----------------
variable "enable_server_backups" {
  type        = bool
  default     = false
  description = "Wether to enable server backups in hcloud."
}

#----------------
# SSH vars
#----------------
variable "ssh_port" {
  type        = number
  default     = 22
  description = "The SSH Port configured and rechable on each machine"
}

variable "ssh_user" {
  type        = string
  default     = "ansible"
  description = "Username of a admin user created on every machine (used by ansible)"
}

variable "ssh_keys" {
  type        = list(string)
  description = "List of (public) ssh keys to configure on the ssh_user"
}

#----------------
# Control Plane
#----------------
variable "master_nodes" {
  type = list(object({
    name        = string
    server_type = string
    image       = string
    labels      = map(string)
    location    = string
    volumes = list(object({
      name    = string
      size_gb = number
    }))
    user_data = string
  }))
  description = "List of master nodes to provision in the cluster, each master node has a set of values you can uniqly configure"
  default = [
    {
      name        = "master-0"
      server_type = "cpx11"
      image       = "debian-11"
      labels      = {}
      location    = "hel1"
      volumes     = []
      user_data   = ""
    }
  ]
}

#----------------
# Compute Plane
#----------------
variable "worker_nodes" {
  type = list(object({
    name        = string
    server_type = string
    image       = string
    labels      = map(string)
    location    = string
    volumes = list(object({
      name    = string
      size_gb = number
    }))
    user_data = string
  }))
  description = "List of worker nodes to provision in the cluster, each master node has a set of values you can uniqly configure"
  default = [
    {
      name        = "worker-0"
      server_type = "cpx31"
      image       = "debian-11"
      labels      = {}
      location    = "nbg1"
      volumes     = []
      user_data   = ""
    }
  ]
}
