
output "vpc" {
    value = yandex_vpc_network.my-vpc.name
}

#output "container_registry" {
#    value = yandex_container_registry.my_reg.id
#}


output "all_vm" {
  value = [
    for serv in local.servers_list : { "name" = serv["name"], "ext_ip" = serv.network_interface.0.nat_ip_address}
  ]
}