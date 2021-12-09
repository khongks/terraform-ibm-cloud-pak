output "cloud_admin_ui" {
  depends_on = [
    data.external.get_apic_endpoints,
  ]
  value = var.enable && length(data.external.get_apic_endpoints) > 0 ? data.external.get_apic_endpoints.0.result.cloud_admin_ui : ""
}

output "api_manager_ui" {
  depends_on = [
    data.external.get_apic_endpoints,
  ]
  value = var.enable && length(data.external.get_apic_endpoints) > 0 ? data.external.get_apic_endpoints.0.result.api_manager_ui : ""
}

output "cp4i_user" {
  depends_on = [
    data.external.get_apic_endpoints,
  ]
  value = var.enable && length(data.external.get_apic_endpoints) > 0 ? data.external.get_apic_endpoints.0.result.username : ""
}

output "cp4i_password" {
  depends_on = [
    data.external.get_apic_endpoints,
  ]
  value = var.enable && length(data.external.get_apic_endpoints) > 0 ? data.external.get_apic_endpoints.0.result.password : ""
}
