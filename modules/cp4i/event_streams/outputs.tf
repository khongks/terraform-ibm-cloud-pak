output "es_ui_endpoint" {
  depends_on = [
    data.external.get_es_endpoints
  ]
  value = var.enable && length(data.external.get_es_endpoints) > 0 ? data.external.get_es_endpoints.0.result.es_ui_endpoint : ""
}

output "es_bootstrap_endpoint" {
  depends_on = [
    data.external.get_es_endpoints
  ]
  value = var.enable && length(data.external.get_es_endpoints) > 0 ? data.external.get_es_endpoints.0.result.es_bootstrap_endpoint : ""
}

output "cp4i_user" {
  depends_on = [
    data.external.get_es_endpoints
  ]
  value = var.enable && length(data.external.get_es_endpoints) > 0 ? data.external.get_es_endpoints.0.result.username : ""
}

output "cp4i_password" {
  depends_on = [
    data.external.get_es_endpoints
  ]
  value = var.enable && length(data.external.get_es_endpoints) > 0 ? data.external.get_es_endpoints.0.result.password : ""
}
