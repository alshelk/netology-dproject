
output "vpc" {
    value = yandex_vpc_network.my-vpc.name
}

output "container_registry" {
    value = yandex_container_registry.my_reg.id
}
