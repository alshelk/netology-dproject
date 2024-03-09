###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "github_token" {
  type        = string
  description = "Github personal access token; https://docs.github.com/en/enterprise-server@3.9/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "bucket" {
  type        = string
  description = "bucket for backend"
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
variable "default_cidr" {
  type        = list(list(string))
  default     = [["192.168.10.0/24"],["192.168.20.0/24"]]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
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

variable "nat_instance_id" {
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
  description = "Nat instance id"
}

variable "vm_nat_name" {
  type        = string
  default     = "nat-inst"
  description = "Nat instance Name"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "ssh user for instances"
}

variable "public_key" {
  type    = string
#  default = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  type    = string
#  default = "~/.ssh/id_rsa.pub"
}

variable "vm_resources" {
  type      = map(number)
  default   = {
    cores         = 2
    memory        = 2
    disk          = 10
    core_fraction = 20
  }
}

variable "k8s_node_instance" {
  type        = object({
    platform_id       = string,
    scheduling_policy = map(bool),
    network_interface = map(bool)
  })
  default     = {
    platform_id = "standard-v1",
    scheduling_policy = { preemptible = true },
    network_interface = { nat = true }
  }
  description = "resource instance variables"
}

variable "count_wnode" {
  type        = number
  default     = 2
  description = "count worker nodes"
}

variable "count_mnode" {
  type        = number
  default     = 1
  description = "count master nodes"
}
