resource "yandex_compute_instance" "nat_instance" {
  name        = var.nats_config.name
  platform_id = "standard-v3"
  zone        = var.default_zone

  resources {
    core_fraction = var.nats_config.main_params.core_fraction
    cores         = var.nats_config.main_params.cores
    memory        = var.nats_config.main_params.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.nats_config.nat_instance_id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat                = var.nats_config.nat
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
  }
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_family
}

#resource "yandex_compute_instance" "mnode" {
#  count = var.count_mnode
#  name = "mnode-${count.index}"
#  platform_id   = var.k8s_node_instance.platform_id
#  hostname = "mnode-${count.index}"
#  resources {
#    cores         = var.vm_resources.cores
#    memory        = var.vm_resources.memory
#    core_fraction = var.vm_resources.core_fraction
#  }
#  boot_disk {
#    initialize_params {
#      image_id = data.yandex_compute_image.ubuntu.image_id
#      size = var.vm_resources.disk
#    }
#  }
#  scheduling_policy {
#    preemptible = var.k8s_node_instance.scheduling_policy.preemptible
#  }
#  network_interface {
#    subnet_id = yandex_vpc_subnet.private.id
#    nat = var.k8s_node_instance.network_interface.nat
#
#  }
#  metadata = {
#      user-data          = data.template_file.cloudinit.rendered
#      serial-port-enable = 1
#  }
#
#  connection {
#    type        = "ssh"
#    user        = "${var.ssh_user}"
#    private_key = "${var.private_key}"
#    host        = self.network_interface[0].nat_ip_address
#  }
#
#  provisioner "remote-exec" {
#    inline = [
#      "sudo echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",
#      "sudo swapoff -a"
#    ]
#  }
#}

resource "yandex_compute_instance" "mnode" {
  count = var.mnode_config.count
  name = "mnode-${count.index}"
  platform_id   = var.mnode_config.platform_id
  hostname = "mnode-${count.index}"
  resources {
    cores         = var.mnode_config.main_params.cores
    memory        = var.mnode_config.main_params.memory
    core_fraction = var.mnode_config.main_params.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = var.mnode_config.main_params.disk
    }
  }
  scheduling_policy {
    preemptible = var.mnode_config.scheduling_policy.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat = var.mnode_config.network_interface.nat

  }
  metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
  }

  connection {
    type          = "ssh"
    user          = "${var.ssh_user}"
    private_key   = "${file("~/.ssh/id_rsa")}"
    host          = self.network_interface[0].ip_address
    bastion_host  = yandex_compute_instance.nat_instance.network_interface.0.nat_ip_address
    bastion_user  = "${var.ssh_user}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "sudo swapoff -a"
    ]
  }
}

resource "yandex_compute_instance" "wnode" {
  count = var.wnode_config.count
  name = "wnode-${count.index}"
  platform_id   = var.wnode_config.platform_id
  hostname = "wnode-${count.index}"
  resources {
    cores         = var.wnode_config.main_params.cores
    memory        = var.wnode_config.main_params.memory
    core_fraction = var.wnode_config.main_params.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = var.wnode_config.main_params.disk
    }
  }
  scheduling_policy {
    preemptible = var.wnode_config.scheduling_policy.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat = var.wnode_config.network_interface.nat

  }
  metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
  }

  connection {
    type          = "ssh"
    user          = "${var.ssh_user}"
    private_key   = "${file("~/.ssh/id_rsa")}"
    host          = self.network_interface[0].ip_address
    bastion_host  = yandex_compute_instance.nat_instance.network_interface.0.nat_ip_address
    bastion_user  = "${var.ssh_user}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "sudo swapoff -a"
    ]
  }
}


#resource "yandex_compute_instance" "wnode" {
#  count = var.count_wnode
#  name = "wnode-${count.index}"
#  platform_id   = var.k8s_node_instance.platform_id
#  hostname = "wnode-${count.index}"
#  resources {
#    cores         = var.vm_resources.cores
#    memory        = var.vm_resources.memory
#    core_fraction = var.vm_resources.core_fraction
#  }
#  boot_disk {
#    initialize_params {
#      image_id = data.yandex_compute_image.ubuntu.image_id
#      size = var.vm_resources.disk
#    }
#  }
#  scheduling_policy {
#    preemptible = var.k8s_node_instance.scheduling_policy.preemptible
#  }
#  network_interface {
#    subnet_id = yandex_vpc_subnet.private.id
#    nat = var.k8s_node_instance.network_interface.nat
#
#  }
#  metadata = {
#      user-data          = data.template_file.cloudinit.rendered
#      serial-port-enable = 1
#  }
#
#  connection {
#    type        = "ssh"
#    user        = "${var.ssh_user}"
#    private_key = "${var.private_key}"
#    host        = self.network_interface[0].nat_ip_address
#  }
#
#  provisioner "remote-exec" {
#    inline = [
#      "sudo echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",
#      "sudo swapoff -a"
#    ]
#  }
#}

data "template_file" "cloudinit" {
  template = "${file("./templates/cloud-init.yml")}"
  vars = {
    username           = var.ssh_user
    ssh_public_key     = "${var.public_key}"
  }
}


