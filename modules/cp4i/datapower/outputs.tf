output "admin" {
  depends_on = [
    data.external.get_dp_endpoints,
  ]
  value = var.enable && length(data.external.get_dp_endpoints) > 0 ? data.external.get_dp_endpoints.0.result.username : ""
}

output "password" {
  depends_on = [
    data.external.get_dp_endpoints,
  ]
  value = var.enable && length(data.external.get_dp_endpoints) > 0 ? data.external.get_dp_endpoints.0.result.password : ""
}
