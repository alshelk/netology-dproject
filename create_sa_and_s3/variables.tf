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

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "bucket_name" {
  type        = string
  default     = "backend-for-diplom"
  description = "bucket for backend"
}

variable "sa_name_s3" {
  type        = string
  default     = "sa-edit-s3"
  description = "service account for backend"
}

variable "sa_roles_s3" {
  type        = list(string)
  default     = ["storage.editor"]
  description = "service account roles"
}

variable "sa_name_cont_reg" {
  type        = string
  default     = "k8s-role-sa-cont-reg"
  description = "service account for backend"
}

variable "sa_roles_cont_reg" {
  type        = list(string)
  default     = ["container-registry.editor"]
  description = "service account roles"
}

