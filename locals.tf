resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=./kubespray/ansible.cfg ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ./kubespray/inventory/mycluster/hosts.yaml ./kubespray/cluster.yml -b -v"
  }

  depends_on = [
    local_file.hosts_cfg
  ]
}

resource "null_resource" "localkubectl" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.mnode[0].network_interface[0].ip_address
      private_key = "${var.private_key}"
      user        = var.ssh_user
      timeout     = "30"
      bastion_host  = yandex_compute_instance.nat_instance.network_interface.0.nat_ip_address
      bastion_user  = "${var.ssh_user}"
    }
    inline = [
      "mkdir /home/${var.ssh_user}/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf /home/${var.ssh_user}/.kube/config",
      "sudo chown ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/.kube/config",
    ]
  }
  
  provisioner "local-exec" {
    command = "scp -oProxyCommand='ssh -W %h:%p ${var.ssh_user}@${yandex_compute_instance.nat_instance.network_interface.0.nat_ip_address}' ${var.ssh_user}@${yandex_compute_instance.mnode[0].network_interface[0].ip_address}:~/.kube/config ~/.kube/config"
  }
  
  depends_on = [
    null_resource.cluster,
  ]
}

resource "null_resource" "monitoring" {
  
  provisioner "local-exec" {
    command = <<EOT
ssh -fNT -L 6443:${yandex_compute_instance.mnode[0].network_interface[0].ip_address}:6443  ${var.ssh_user}@${yandex_compute_instance.nat_instance.network_interface.0.nat_ip_address} 
kubectl apply --server-side -f ${path.module}/kube-prometheus/manifests/setup 
kubectl wait --for condition=Established --all CustomResourceDefinition --namespace=monitoring 
sleep 60  
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

resource "null_resource" "docker_login" {
  
  provisioner "local-exec" {
    command = <<EOT
yc iam key create --folder-id "${var.folder_id}" --service-account-name "${var.sa_name_cont_reg}" -o key.json 
cat key.json | docker login --username json_key --password-stdin cr.yandex
kubectl apply -f ../simpleApp/K8s/
kubectl create secret generic ycregistry --namespace=app --from-file=.dockerconfigjson=/home/vagrant/.docker/config.json  --type=kubernetes.io/dockerconfigjson
EOT
  }

  depends_on = [
    null_resource.localkubectl
  ]
}
