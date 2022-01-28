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

variable "region" {
  type        = string
  description = "In which region should your cluster be?"
  validation {
    condition     = can(regex("(eu-central|us-east)", var.region))
    error_message = "The region must be one of the following values: [eu-central, us-east]."
  }
}

variable "ssh_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Limit the ips that are allowed to ssh into our cluster nodes."
}

variable "cluster_vpc_cidr" {
  type        = string
  default     = "10.123.0.0/16"
  description = "A valid CIDR for the cluster network (multiple subnets within that network will be created)"
}

variable "cluster_subnet_cidr" {
  type        = string
  default     = "10.123.1.0/24"
  description = "A valid CIDR within the cluster_vpc_cidr"
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

variable "ip_mode" {
  type        = string
  default     = "ipv6"
  description = "All in on IPv4 or IPv6?"
  validation {
    condition     = can(regex("(ipv4|ipv6)", var.ip_mode))
    error_message = "The ip_mode must either by 'ipv4' or 'ipv6'."
  }
}

#----------------
# SSH vars (default)
#----------------
variable "default_ssh_port" {
  type        = number
  default     = 22
  description = "The default SSH Port configured and rechable on each machine"
}

variable "default_ssh_user" {
  type        = string
  default     = "ansible"
  description = "Username of a default admin user created on every machine (used by ansible)"
}

variable "default_ssh_keys" {
  type        = list(string)
  description = "List of default (public) ssh keys to configure on the ssh_user"
}

#----------------
# Control Plane vars
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
    ssh_user = string
    ssh_keys = list(string)
    ssh_port = number
  }))
  description = "List of master nodes to provision in the cluster, each master node has a set of values you can configure, ssh_* variables use the default if omitted"
  default = [
    {
      name        = "master-0"
      server_type = "cpx11"
      image       = "debian-11"
      labels      = {}
      location    = "hel1"
      volumes     = []
      ssh_user    = ""
      ssh_keys    = []
      ssh_port    = 0
    }
  ]
}

variable "kubeapi_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Limit the ips that are allowed to talk to our kubeapi. (Worker-nodes will always be allowed)"
}

#----------------
# Worker node vars
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
    ssh_user = string
    ssh_keys = list(string)
    ssh_port = number
  }))
  description = "List of worker nodes to provision in the cluster, each master node has a set of values you can configure, ssh_* variables use the default if omitted"
  default = [
    {
      name        = "worker-0"
      server_type = "cpx31"
      image       = "debian-11"
      labels      = {}
      location    = "nbg1"
      volumes     = []
      ssh_user    = ""
      ssh_keys    = []
      ssh_port    = 0
    }
  ]
}

variable "nodeport_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Who is allowed to connect to your nodeport services (e.g only a LoadBalancer...)"
}
