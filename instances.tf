data "yandex_compute_image" "ubuntu" {
  family = var.vm_family
}

resource "yandex_compute_instance" "mnode" {
  count = var.count_mnode  
  name = "mnode-${count.index}"
  platform_id   = var.k8s_node_instance.platform_id
  hostname = "mnode-${count.index}"
  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = var.vm_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = var.vm_resources.disk
    }
  }
  scheduling_policy {
    preemptible = var.k8s_node_instance.scheduling_policy.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat = var.k8s_node_instance.network_interface.nat

  }
  metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
  }
  
  connection {
    type        = "ssh"
    user        = "${var.ssh_user}"
    private_key = "${var.private_key}"
    host        = self.network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",
      "sudo swapoff -a"
    ]
  }
}

resource "yandex_compute_instance" "wnode" {
  count = var.count_wnode
  name = "wnode-${count.index}"
  platform_id   = var.k8s_node_instance.platform_id
  hostname = "wnode-${count.index}"
  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = var.vm_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = var.vm_resources.disk
    }
  }
  scheduling_policy {
    preemptible = var.k8s_node_instance.scheduling_policy.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat = var.k8s_node_instance.network_interface.nat

  }
  metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
  }
  
  connection {
    type        = "ssh"
    user        = "${var.ssh_user}"
    private_key = "${var.private_key}"
    host        = self.network_interface[0].nat_ip_address
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",
      "sudo swapoff -a"
    ]
  }
}

data "template_file" "cloudinit" {
  template = "${file("./templates/cloud-init.yml")}"
  vars = {
    username           = var.ssh_user
    ssh_public_key     = "${var.public_key}"
  }
}

#data "yandex_compute_image" "jenkins" {
#  family = "jenkins"
#}

#resource "yandex_compute_instance" "jenkins" {
#  name = "jenkins"
#  platform_id   = var.k8s_node_instance.platform_id
#  hostname = "jenkins"
#  resources {
#    cores         = var.vm_resources.cores
#    memory        = var.vm_resources.memory
#    core_fraction = var.vm_resources.core_fraction
#  }
#  boot_disk {
#    initialize_params {
#      image_id = data.yandex_compute_image.jenkins.image_id
#      size = var.vm_resources.disk
#    }
#  }
#  scheduling_policy {
#    preemptible = var.k8s_node_instance.scheduling_policy.preemptible
#  }
#  network_interface {
#    subnet_id = yandex_vpc_subnet.public.id
#    nat = var.k8s_node_instance.network_interface.nat
#
#  }
#  metadata = {
#      user-data          = data.template_file.cloudinit.rendered
#      serial-port-enable = 1
#  }
#
#}
