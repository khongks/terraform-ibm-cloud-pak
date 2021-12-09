locals {
  ace_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-appconnect"
    namespace            = var.operator_namespace
    channel_version      = var.ace_designer.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })

  ace_designer_content = templatefile("${path.module}/../templates/ace_designer.yaml.tmpl", {
    namespace           = var.ace_designer.namespace
    release_name        = var.ace_designer.release_name
    use                 = var.ace_designer.use
    replicas            = var.ace_designer.replicas
    storageclass        = var.ace_designer.storageclass
    license             = var.ace_designer.license
    version             = var.ace_designer.version
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_ace_designer" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1        = sha1(var.ace_designer.namespace)
    docker_params_sha1    = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ace_subscription_sha1 = sha1(local.ace_subscription_content)
    ace_designer_sha1     = sha1(local.ace_designer_content)
  }

  provisioner "local-exec" {
    command     = "./install_ace_designer.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                      = var.cluster_config_path
      OPERATOR_NAMESPACE              = var.operator_namespace
      ACE_NAMESPACE                   = var.ace_designer.namespace
      STORAGECLASS                    = var.ace_designer.storageclass
      RELEASE_NAME                    = var.ace_designer.release_name
      SUBSCRIPTION_NAME               = "ibm-appconnect"
      ACE_SUBSCRIPTION_CONTENT        = local.ace_subscription_content
      ACE_DESIGNER_CONTENT            = local.ace_designer_content
      DOCKER_REGISTRY_PASSWORD        = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL      = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME        = local.entitled_registry_user
      DOCKER_REGISTRY                 = local.entitled_registry
    }
  }
}

data "external" "get_ace_designer_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_ace_designer
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_ace_designer_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.ace_designer.namespace
  }
}