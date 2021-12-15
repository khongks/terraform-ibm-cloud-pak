locals {
  aspera_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "aspera-hsts-operator"
    namespace            = var.operator_namespace
    channel_version      = var.aspera.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })
  aspera_content = templatefile("${path.module}/../templates/aspera/aspera.yaml.tmpl", {
    namespace         = var.aspera.namespace
    release_name      = var.aspera.release_name
    use               = var.aspera.use
    storageclass      = var.aspera.storageclass
    version           = var.aspera.version
    aspera_key        = var.aspera.aspera_key
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_aspera" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1          = sha1(var.aspera.namespace)
    docker_params_sha1      = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    aspera_subscription_sha1  = sha1(local.aspera_subscription_content)
    aspera_sha1               = sha1(local.aspera_content)
  }

  provisioner "local-exec" {
    command     = "./install_aspera.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      OPERATOR_NAMESPACE            = var.operator_namespace
      ASPERA_NAMESPACE              = var.aspera.namespace
      STORAGECLASS                  = var.aspera.storageclass
      RELEASE_NAME                  = var.aspera.release_name
      SUBSCRIPTION_NAME             = "aspera-hsts-operator"
      ASPERA_SUBSCRIPTION_CONTENT   = local.aspera_subscription_content
      ASPERA_CONTENT                = local.aspera_content
      DOCKER_REGISTRY_PASSWORD      = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME      = local.entitled_registry_user
      DOCKER_REGISTRY               = local.entitled_registry
    }
  }
}

data "external" "get_aspera_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_aspera
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_aspera_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.aspera.namespace
    release_name = var.aspera.release_name
  }
}
