[all]
${connection_strings_master}
${connection_strings_worker}

[kube-master]
${list_masters}

[etcd]
${list_masters}

[kube-node]
${list_workers}

[k8s-cluster:children]
kube-master
kube-node
