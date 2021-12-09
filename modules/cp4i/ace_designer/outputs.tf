output "ace_designer_endpoint" {
  depends_on = [
    data.external.get_ace_designer_endpoints,
  ]
  value = var.enable && length(data.external.get_ace_designer_endpoints) > 0 ? data.external.get_ace_designer_endpoints.0.result.endpoint : ""
}

output "cp4i_user" {
  depends_on = [
    data.external.get_ace_designer_endpoints,
  ]
  value = var.enable && length(data.external.get_ace_designer_endpoints) > 0 ? data.external.get_ace_designer_endpoints.0.result.username : ""
}

output "cp4i_password" {
  depends_on = [
    data.external.get_ace_designer_endpoints,
  ]
  value = var.enable && length(data.external.get_ace_designer_endpoints) > 0 ? data.external.get_ace_designer_endpoints.0.result.password : ""
}
