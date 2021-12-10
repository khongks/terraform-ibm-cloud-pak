locals {
  es_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-eventstreams"
    namespace            = var.operator_namespace
    channel_version      = var.es.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })
  es_content = templatefile("${path.module}/../templates/event_streams/development.yaml.tmpl", {
    namespace         = var.es.namespace
    release_name      = var.es.release_name
    use               = var.es.use
    storageclass      = var.es.storageclass
    version           = var.es.version
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_es" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1          = sha1(var.es.namespace)
    docker_params_sha1      = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    es_subscription_sha1  = sha1(local.es_subscription_content)
    es_sha1               = sha1(local.es_content)
  }

  provisioner "local-exec" {
    command     = "./install_es.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      OPERATOR_NAMESPACE            = var.operator_namespace
      ES_NAMESPACE                  = var.es.namespace
      STORAGECLASS                  = var.es.storageclass
      RELEASE_NAME                  = var.es.release_name
      SUBSCRIPTION_NAME             = "ibm-eventstreams"
      ES_SUBSCRIPTION_CONTENT       = local.es_subscription_content
      ES_CONTENT                    = local.es_content
      DOCKER_REGISTRY_PASSWORD      = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME      = local.entitled_registry_user
      DOCKER_REGISTRY               = local.entitled_registry
    }
  }
}

data "external" "get_es_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_es
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_es_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.es.namespace
    release_name = var.es.release_name
  }
}
