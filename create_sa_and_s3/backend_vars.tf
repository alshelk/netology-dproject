
resource "local_file" "backend_vars" {
  content = templatefile("${path.module}/secret.backend.tfvars.tftpl",
    { access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key,
      secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key,
      bucket = var.bucket_name }
  )

  filename = "${abspath(path.module)}/../secret.backend.tfvars"
  
  depends_on = [
    yandex_iam_service_account_static_access_key.sa-static-key
  ]
}
