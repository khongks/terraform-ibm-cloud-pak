locals {
  ace_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-appconnect"
    namespace            = var.operator_namespace
    channel_version      = var.ace_dashboard.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })

  ace_dashboard_content = templatefile("${path.module}/../templates/ace/ace_dashboard.yaml.tmpl", {
    namespace           = var.ace_dashboard.namespace
    release_name        = var.ace_dashboard.release_name
    use                 = var.ace_dashboard.use
    replicas            = var.ace_dashboard.replicas
    storageclass        = var.ace_dashboard.storageclass
    license             = var.ace_dashboard.license
    version             = var.ace_dashboard.version
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_ace_dashboard" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1        = sha1(var.ace_dashboard.namespace)
    docker_params_sha1    = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ace_subscription_sha1 = sha1(local.ace_subscription_content)
    ace_dashboard_sha1    = sha1(local.ace_dashboard_content)
  }

  provisioner "local-exec" {
    command     = "./install_ace_dashboard.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                      = var.cluster_config_path
      OPERATOR_NAMESPACE              = var.operator_namespace
      ACE_NAMESPACE                   = var.ace_dashboard.namespace
      STORAGECLASS                    = var.ace_dashboard.storageclass
      RELEASE_NAME                    = var.ace_dashboard.release_name
      SUBSCRIPTION_NAME               = "ibm-appconnect"
      ACE_SUBSCRIPTION_CONTENT        = local.ace_subscription_content
      ACE_DASHBOARD_CONTENT           = local.ace_dashboard_content
      DOCKER_REGISTRY_PASSWORD        = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL      = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME        = local.entitled_registry_user
      DOCKER_REGISTRY                 = local.entitled_registry
    }
  }
}

data "external" "get_ace_dashboard_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_ace_dashboard
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_ace_dashboard_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.ace_dashboard.namespace
  }
}
