resource "yandex_container_registry" "my_reg" {
  name = "my-registry"
  folder_id = var.folder_id
  labels = {
    my-label = "my-label-value"
  }
}

resource "yandex_container_registry_iam_binding" "editor" {
  registry_id = yandex_container_registry.my_reg.id
  role        = "container-registry.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}
