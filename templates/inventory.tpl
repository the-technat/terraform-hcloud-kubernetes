[all]
${connection_strings_master}
${connection_strings_worker}

[kube-master]
${connection_strings_master}

[etcd]
${connection_strings_master}

[kube-node]
${connection_strings_worker}

[k8s-cluster:children]
kube-master
kube-node
