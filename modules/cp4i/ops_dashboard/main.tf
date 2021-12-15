locals {
  ops_dashboard_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-integration-operations-dashboard"
    namespace            = var.operator_namespace
    channel_version      = var.ops_dashboard.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })

  ops_dashboard_content = templatefile("${path.module}/../templates/ops_dashboard/ops_dashboard.yaml.tmpl", {
    namespace             = var.ops_dashboard.namespace
    release_name          = var.ops_dashboard.release_name
    file_storageclass     = var.ops_dashboard.file_storageclass
    block_storageclass    = var.ops_dashboard.block_storageclass
    license               = var.ops_dashboard.license
    version               = var.ops_dashboard.version
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_ops_dashboard" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1                    = sha1(var.ops_dashboard.namespace)
    docker_params_sha1                = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ops_dashboard_subscription_sha1   = sha1(local.ops_dashboard_subscription_content)
    ops_dashboard_content_sha1        = sha1(local.ops_dashboard_content)
  }

  provisioner "local-exec" {
    command     = "./install_ops_dashboard.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                            = var.cluster_config_path
      OPERATOR_NAMESPACE                    = var.operator_namespace
      OPS_DASHBOARD_NAMESPACE               = var.ops_dashboard.namespace
      FILE_STORAGECLASS                     = var.ops_dashboard.file_storageclass
      BLOCK_STORAGECLASS                    = var.ops_dashboard.block_storageclass
      RELEASE_NAME                          = var.ops_dashboard.release_name
      SUBSCRIPTION_NAME                     = "ibm-integration-operations-dashboard"
      OPS_DASHBOARD_SUBSCRIPTION_CONTENT    = local.ops_dashboard_subscription_content
      OPS_DASHBOARD_CONTENT                 = local.ops_dashboard_content
      DOCKER_REGISTRY_PASSWORD              = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL            = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME              = local.entitled_registry_user
      DOCKER_REGISTRY                       = local.entitled_registry
    }
  }
}

data "external" "get_ops_dashboard_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_ops_dashboard
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_ops_dashboard_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.ops_dashboard.namespace
    release_name = var.ops_dashboard.release_name
  }
}
