terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

terraform {
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"

    region = "ru-central1"
    key    = "backend/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}