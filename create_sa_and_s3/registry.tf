resource "yandex_container_registry" "my_reg" {
  name = "my-registry"
  folder_id = var.folder_id
  labels = {
    my-label = "my-label-value"
  }
}

resource "yandex_iam_service_account" "sa-cont-reg" {
  name = var.sa_name_cont_reg
}

resource "yandex_container_registry_iam_binding" "editor" {
  for_each = toset(var.sa_roles_cont_reg)
  registry_id = yandex_container_registry.my_reg.id
  role        = each.key

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-cont-reg.id}",
  ]
  depends_on = [
    yandex_iam_service_account.sa-cont-reg,
    yandex_container_registry.my_reg
  ]
}
