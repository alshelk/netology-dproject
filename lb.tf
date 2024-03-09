resource "yandex_lb_target_group" "k8s_tg" {
  name = "k8s-target-group"

  dynamic "target" {
    for_each = concat([for instance in yandex_compute_instance.mnode : {
      address   = instance.network_interface.0.ip_address
      subnet_id = instance.network_interface.0.subnet_id
    }], [for instance in yandex_compute_instance.wnode : {
      address   = instance.network_interface.0.ip_address
      subnet_id = instance.network_interface.0.subnet_id
    }])

    content {
      subnet_id = target.value.subnet_id
      address   = target.value.address
    }
  }
}

resource "yandex_lb_network_load_balancer" "k8s-lb" {
  name = "k8s-load-balancer"

  listener {
    name        = "grafana-listener"
    port        = 80
    target_port = 30000
    external_address_spec {
      ip_version = "ipv4"
#      address    = yandex_vpc_address.addr-k8s.external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_tg.id

    healthcheck {
      name = "http"
      http_options {
        port = 30000
        path = "/login"
      }
    }
  }
}




resource "yandex_alb_target_group" "k8s-atg" {
  name = "k8s-alb-target-group"
  
  dynamic "target" {
    for_each = concat([for instance in yandex_compute_instance.mnode : {
      address   = instance.network_interface.0.ip_address
      subnet_id = instance.network_interface.0.subnet_id
    }], [for instance in yandex_compute_instance.wnode : {
      address   = instance.network_interface.0.ip_address
      subnet_id = instance.network_interface.0.subnet_id
    }])

    content {
      subnet_id  = target.value.subnet_id
      ip_address = target.value.address
    }
  }
}

resource "yandex_alb_backend_group" "k8s-backend-group" {
  name = "k8s-backend-group"

  http_backend {
    name             = "k8s-http-backend"
    weight           = 1
    port             = 30001
    target_group_ids = ["${yandex_alb_target_group.k8s-atg.id}"]
    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout             = "1s"
      interval            = "1s"
      healthy_threshold   = 1
      unhealthy_threshold = 3
      healthcheck_port    = "30001"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "k8s-tf-router" {
  name = "k8s-http-router"
}

resource "yandex_alb_virtual_host" "k8s-virtual-host" {
  name           = "k8s-virtual-host"
  http_router_id = yandex_alb_http_router.k8s-tf-router.id
  route {
    name = "k8s-http-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.k8s-backend-group.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "k8s-alb" {
  name = "k8s-application-load-balancer"

  network_id = yandex_vpc_network.my-vpc.id

  allocation_policy {
    location {
      zone_id   = var.default_zone
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "k8s-alb-listener"
    endpoint {
      address {
        external_ipv4_address {
#          address = yandex_vpc_address.addr-web.external_ipv4_address[0].address
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.k8s-tf-router.id
      }
    }
  }
  
  depends_on = [
    null_resource.monitoring
  ]
}

