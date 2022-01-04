#----------------
# General Vars
#----------------
variable "common_labels" {
  type = map(string)
  default = {}
  description = "Common map of labels to add on all resources"
}

#----------------
# Control Plane vars
#----------------
variable control_plane_node_count {
  type = number
  default = 3
  description = "How many master nodes do you want?"
}


