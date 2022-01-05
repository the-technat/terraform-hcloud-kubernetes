#----------------
# General Vars
#----------------
variable "common_labels" {
  type = map(string)
  default = {}
  description = "Common map of labels to add on all resources"
}
variable "cluster_name" {
  type = string
  description = "A cluster-name that is used to suffix every resource name"  
}

variable "region" { 
  type = string 
  description = "In which region should your cluster be?"
  validation {
    condition = can(regex("(hel1|ash|nbg1|fsn1)", var.region))
    error_message = "The region must be one of the following values: [hel1, ash, ngb1, fsn1]."
  }
}

variable "ssh_source_ips" {
  type = list(string) 
  default = [ "0.0.0.0/0", "::/0" ]
  description = "Limit the ips that are allowed to ssh into our cluster nodes."
}

variable "cluster_vpc_cidr" {
  type = string
  default = "10.123.0.0/16" 
  description = "A valid CIDR for the cluster network (multiple subnets within that network will be created)"
}

variable "cluster_subnet_cidr" {
  type = string
  default = "10.123.1.0/24" 
  description = "A valid CIDR within the cluster_vpc_cidr"
}

#----------------
# Toggle Vars
# Switch things on and off
#----------------

variable "enable_server_backups" {
  type = bool
  default = false
  description = "Wether to enable server backups in hcloud."
}

#----------------
# Control Plane vars
#----------------
variable "kubeapi_ip_type" {
  type = string
  default = "ipv6"
  description = "Should your kubeapi be rechable on an IPv4 or IPv6 address?"
  validation {
    condition = can(regex("(ipv4|ipv6)", var.kubeapi_ip_type))
    error_message = "The kubeapi_ip_type must either by 'ipv4' or 'ipv6'."
  }
}

variable "master_node_template" {
  type = object({
    prefix = string 
    server_type = string 
    image = string
    ci_user = string
    ssh_keys = list(string)
    ssh_port = number
  })
  description = "A template how a master node is provisioned"
  # default = {
  #   image = "debian-11"
  #   server_type = "cpx11"
  #   prefix = "master"
  #   ci_user = "ci"
  #   ci_user_ssh_keys = []
  #   ssh_port = 58222
  # }
}

variable "master_node_count" {
  type = number 
  default = 3
  description = "How many master nodes do you want?"
  validation {
    condition = can(regex("^\\d*[13579]$", var.master_node_count))
    error_message = "The master_node_count must be an odd number for optimal reliability."
  }
}

variable "kubeapi_source_ips" {
  type = list(string)
  default = [ "0.0.0.0/0", "::/0" ]
  description = "Limit the ips that are allowed to talk to our kubeapi. (Worker-nodes will always be allowed)"
}

#----------------
# Worker node vars
#----------------
variable "worker_node_template" {
  type = object({
    prefix = string 
    server_type = string 
    image = string
    ci_user = string
    ssh_keys = list(string)
    ssh_port = number
  })
  description = "A template how a worker node is provisioned"
  # default = {
  #   image = "debian-11"
  #   server_type = "cpx31"
  #   prefix = "master"
  #   ci_user = "ci"
  #   ci_user_ssh_keys = []
  #   ssh_port = 58222
  # }
}

variable "worker_node_count" {
  type = number 
  description = "How many worker nodes do you want?"
  default = 3
}

variable "nodeport_source_ips" {
  type = list(string) 
  default = [ "0.0.0.0/0", "::/0" ]
  description = "How is allowed to connect to your nodeport servics (e.g only a LoadBalancer...)"
}
