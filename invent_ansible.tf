
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tftpl",
    { masternodes = yandex_compute_instance.mnode,
      workernodes = yandex_compute_instance.wnode,
      user = var.ssh_user }
  )

  filename = "${abspath(path.module)}/kubespray/inventory/mycluster/hosts.yaml"
  
  depends_on = [
    yandex_compute_instance.mnode,
    yandex_compute_instance.wnode
  ]
}

resource "local_file" "k8s-cluster" {
  content = templatefile("${path.module}/templates/k8s-cluster.yml.tftpl",
    { cluster_ip = yandex_compute_instance.mnode[0].network_interface[0].nat_ip_address,
    }
  )

  filename = "${abspath(path.module)}/kubespray/inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml"
  
  depends_on = [
    yandex_compute_instance.mnode
  ]
}



