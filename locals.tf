resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=./kubespray/ansible.cfg ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ./kubespray/inventory/mycluster/hosts.yaml ./kubespray/cluster.yml -b -v"
  }

  depends_on = [
    local_file.hosts_cfg
  ]
}

resource "time_sleep" "wait_2_minutes" {
  create_duration = "120s"
}

resource "null_resource" "localkubectl" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.mnode[0].network_interface[0].nat_ip_address
      private_key = file("~/.ssh/id_rsa")
      user        = var.ssh_user
      timeout     = "30"
    }
    inline = [
      "mkdir /home/${var.ssh_user}/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf /home/${var.ssh_user}/.kube/config",
      "sudo chown ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/.kube/config",
    ]
  }
  
  provisioner "local-exec" {
    command = "scp ${var.ssh_user}@${yandex_compute_instance.mnode[0].network_interface[0].nat_ip_address}:~/.kube/config ~/.kube/config && sed -i 's/127.0.0.1/${yandex_compute_instance.mnode[0].network_interface[0].nat_ip_address}/' ~/.kube/config"
  }
  
  depends_on = [
    null_resource.cluster,
    time_sleep.wait_2_minutes
  ]
}

resource "null_resource" "monitoring" {
  
  provisioner "local-exec" {
    command = <<EOT
kubectl apply --server-side -f ${path.module}/kube-prometheus/manifests/setup
kubectl wait --for condition=Established --all CustomResourceDefinition --namespace=monitoring 
kubectl apply -f ${path.module}/kube-prometheus/manifests/ 
EOT
  }
  
  depends_on = [
    null_resource.localkubectl
  ]
}

locals {
  servers_list = concat([ for i in yandex_compute_instance.mnode : i], [ for i in yandex_compute_instance.wnode : i])
  depends_on = [
    yandex_compute_instance.mnode,
    yandex_compute_instance.wnode
  ]
}