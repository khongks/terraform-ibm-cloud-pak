locals {
  emm_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-apiconnect"
    namespace            = var.operator_namespace
    channel_version      = var.emm.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })
  emm_content = templatefile("${path.module}/../templates/emm/emm.yaml.tmpl", {
    namespace         = var.emm.namespace
    release_name      = var.emm.release_name
    use               = var.emm.use
    profile           = var.emm.profile
    storageclass      = var.emm.storageclass
    license           = var.emm.license
    version           = var.emm.version
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_emm" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1          = sha1(var.emm.namespace)
    docker_params_sha1      = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    emm_subscription_sha1  = sha1(local.emm_subscription_content)
    emm_sha1               = sha1(local.emm_content)
  }

  provisioner "local-exec" {
    command     = "./install_emm.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      OPERATOR_NAMESPACE            = var.operator_namespace
      EMM_NAMESPACE                 = var.emm.namespace
      STORAGECLASS                  = var.emm.storageclass
      RELEASE_NAME                  = var.emm.release_name
      SUBSCRIPTION_NAME             = "ibm-apiconnect"
      EMM_SUBSCRIPTION_CONTENT      = local.emm_subscription_content
      EMM_CONTENT                   = local.emm_content
      DOCKER_REGISTRY_PASSWORD      = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME      = local.entitled_registry_user
      DOCKER_REGISTRY               = local.entitled_registry
    }
  }
}

data "external" "get_emm_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_emm
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_emm_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.emm.namespace
    release_name = var.emm.release_name
  }
}
