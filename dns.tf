#
#resource "yandex_dns_zone" "zone1" {
#  name        = "my-public-zone"
#  description = "Public zone"
#
#  labels = {
#    label1 = "my-public"
#  }
#
#  zone    = "dp-zone.ru."
#  public  = true
#}
#
#resource "yandex_dns_recordset" "rs-app-web" {
#  zone_id = var.dns_zone_id
#  name    = "myapp.dp-zone.ru."
#  type    = "A"
#  ttl     = 200
#  data    = ["${yandex_vpc_address.addr-web.external_ipv4_address[0].address}"]
#}
#
#resource "yandex_dns_recordset" "rs-grafana" {
#  zone_id = var.dns_zone_id
#  name    = "k8s.dp-myzone.ru."
#  type    = "A"
#  ttl     = 200
#  data    = ["${yandex_vpc_address.addr-k8s.external_ipv4_address[0].address}"]
#}
