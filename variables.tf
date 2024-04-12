###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

### networks vars

variable "vpc_name" {
  type        = string
  default     = "my-vpc"
  description = "VPC network name"
}
variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "subnets_name" {
  type        = list(string)
  default     = ["public", "private"]
  description = "subnets name"
}

variable "cidr" {
  type      = map(list(string))
  default   = {
    public     = ["192.168.10.0/24"]
    private    = ["192.168.20.0/24"]
  }
}

variable "dns_zone_id" {
  type    = string
  default = "dns2njvtqjticn9q5lf4"
}

### service account

variable "sa_name" {
  type        = string
  default     = "sa-edit-inf"
  description = "service account for backend"
}

variable "sa_roles" {
  type        = list(string)
  default     = ["editor"]
  description = "service account roles"
}

###instances vars
variable "vm_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "OS family & release"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "ssh user for instances"
}

variable "public_key" {
  type    = string
}

variable "private_key" {
  type    = string
}

variable "sa_name_cont_reg" {
  type        = string
  default     = "k8s-role-sa-cont-reg"
  description = "service account for backend"
}

variable "registry_id" {
  type        = string
  default     = "crp7lguopi1pjrhap18j"
  description = "yc docker registry"
}

variable "nats_config" {
  type        = object({
    name              = string,
    main_params       = map(number),
    nat_instance_id   = string,
    nat               = bool,
    subnet_name       = string
  })
  default   = {
    name              = "nat-for-public"
    main_params       = {
      cores             = 2
      memory            = 2
      disk              = 10
      core_fraction     = 20
    },
    nat_instance_id   = "fd80mrhj8fl2oe87o4e1",
    nat               = true,
    subnet_name       = "public"
  
  }
}

variable "mnode_config" {
  type        = object({
    count             = number,
    main_params       = map(number),
    nat               = bool,
    subnet_name       = string,
    platform_id       = string,
    scheduling_policy = map(bool),
    network_interface = map(bool)
  })
  default   = {
    count             = 1,
    main_params       = {
      cores             = 2
      memory            = 2
      disk              = 10
      core_fraction     = 20
    },
    nat               = false,
    subnet_name       = "private"
    platform_id       = "standard-v1",
    scheduling_policy = { preemptible = false },
    network_interface = { nat = false }
  }
}

variable "wnode_config" {
  type        = object({
    count             = number,
    main_params       = map(number),
    nat               = bool,
    subnet_name       = string,
    platform_id       = string,
    scheduling_policy = map(bool),
    network_interface = map(bool)
  })
  default   = {
    count             = 2,
    main_params       = {
      cores             = 2
      memory            = 2
      disk              = 10
      core_fraction     = 20
    },
    nat               = false,
    subnet_name       = "private"
    platform_id       = "standard-v1",
    scheduling_policy = { preemptible = false },
    network_interface = { nat = false }
  }
}
