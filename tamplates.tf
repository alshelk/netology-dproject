
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tftpl",
    { masternodes = yandex_compute_instance.mnode,
      workernodes = yandex_compute_instance.wnode,
      nat = yandex_compute_instance.nat_instance,
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

resource "local_file" "qbec" {
  content = templatefile("${path.module}/templates/qbec.yaml.tftpl",
    { cluster_ip = yandex_compute_instance.mnode[0].network_interface[0].nat_ip_address,
    }
  )

  filename = "${abspath(path.module)}/../simpleApp/qbec.yaml"
  
  depends_on = [
    yandex_compute_instance.mnode
  ]
}

resource "local_file" "Deployment" {
  content = templatefile("${path.module}/templates/Deployment.yml.tftpl",
    { registry_id = var.registry_id,
    }
  )

  filename = "${abspath(path.module)}/../simpleApp/K8s/Deployment.yml"
  
  depends_on = [
    yandex_compute_instance.mnode
  ]
}

resource "local_file" "libsonnet" {
  content = templatefile("${path.module}/templates/default.libsonnet.tftpl",
    { registry_id = var.registry_id,
    }
  )

  filename = "${abspath(path.module)}/../simpleApp/environments/default.libsonnet"
  
  depends_on = [
    yandex_compute_instance.mnode
  ]
}


