locals {
  dp_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "datapower-operator"
    namespace            = var.operator_namespace
    channel_version      = var.dp.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })
  dp_content = templatefile("${path.module}/../templates/datapower/dp.yaml.tmpl", {
    namespace         = var.dp.namespace
    release_name      = var.dp.release_name
    use               = var.dp.use
    storageclass      = var.dp.storageclass
    license           = var.dp.license
    version           = var.dp.version
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_dp" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1          = sha1(var.dp.namespace)
    docker_params_sha1      = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    dp_subscription_sha1    = sha1(local.dp_subscription_content)
    dp_sha1                 = sha1(local.dp_content)
  }

  provisioner "local-exec" {
    command     = "./install_dp.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      OPERATOR_NAMESPACE            = var.operator_namespace
      DP_NAMESPACE                  = var.dp.namespace
      STORAGECLASS                  = var.dp.storageclass
      RELEASE_NAME                  = var.dp.release_name
      SUBSCRIPTION_NAME             = "datapower-operator"
      DP_SUBSCRIPTION_CONTENT       = local.dp_subscription_content
      DP_CONTENT                    = local.dp_content
      DOCKER_REGISTRY_PASSWORD      = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME      = local.entitled_registry_user
      DOCKER_REGISTRY               = local.entitled_registry
    }
  }
}

data "external" "get_dp_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_dp
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_dp_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.dp.namespace
    release_name = var.dp.release_name
  }
}
