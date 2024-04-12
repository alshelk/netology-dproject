resource "yandex_vpc_network" "my-vpc" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.subnets_name[0]
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my-vpc.id
  v4_cidr_blocks = "${lookup(var.cidr, var.subnets_name[0])}"
}

resource "yandex_vpc_subnet" "private" {
  name           = var.subnets_name[1]
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my-vpc.id
  v4_cidr_blocks = "${lookup(var.cidr, var.subnets_name[1])}"
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = "nat-instance-sg"
  network_id = yandex_vpc_network.my-vpc.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  
  ingress {
    protocol       = "TCP"
    description    = "api-k8s"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }
  ingress {
    protocol       = "TCP"
    description    = "kubelet-k8s"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10250
  }  
  ingress {
    protocol       = "TCP"
    description    = "kubelet-api-k8s"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10255
  }      
  ingress {
    protocol       = "TCP"
    description    = "k8s-port"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 65535
  }
}

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.my-vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance.network_interface.0.ip_address
  }
}
