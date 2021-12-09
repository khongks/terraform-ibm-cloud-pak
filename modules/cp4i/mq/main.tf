locals {
  mq_subscription_content = templatefile("${path.module}/../templates/mq_subscription.yaml.tmpl", {
    namespace            = var.mq.namespace
    channel_version      = var.mq.channel_version
  })
mq_content = templatefile("${path.module}/../templates/mq.yaml.tmpl", {
    namespace       = var.mq.namespace
    release_name    = var.mq.release_name
    use             = var.mq.use
    replicas        = var.mq.replicas
    storageclass    = var.mq.storageclass
    license         = var.mq.license
    version         = var.mq.version
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "create_mqsc_cmap" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1        = sha1(var.mq.namespace)
    docker_params_sha1    = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    mq_subscription_sha1 = sha1(local.mq_content)
    mq_sha1    = sha1(local.mq_content)
  }

  provisioner "local-exec" {
    command     = "./create_mqsc_cmap.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                = var.cluster_config_path
      NAMESPACE                 = var.mq.namespace
      STORAGECLASS              = var.mq.storageclass
      RELEASE_NAME              = var.mq.release_name
      MQ_SUBSCRIPTION_CONTENT   = local.mq_content
      MQ_CONTENT                = local.mq
      DOCKER_REGISTRY_PASS      = local.entitled_registry_key
      DOCKER_USER_EMAIL         = var.entitled_registry_user_email
      DOCKER_USERNAME           = local.entitled_registry_user
      DOCKER_REGISTRY           = local.entitled_registry
      DOCKER_REGISTRY_PASS      = var.entitled_registry_key
    }
  }
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_mq" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1        = sha1(var.mq.namespace)
    docker_params_sha1    = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    mq_subscription_sha1 = sha1(local.mq_content)
    mq_sha1    = sha1(local.mq_content)
  }

  provisioner "local-exec" {
    command     = "./install_mq.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                = var.cluster_config_path
      NAMESPACE                 = var.mq.namespace
      STORAGECLASS              = var.mq.storageclass
      RELEASE_NAME              = var.mq.release_name
      ACE_SUBSCRIPTION_CONTENT  = local.mq_content
      ACE_DASHBOARD_CONTENT     = local.mq
      DOCKER_REGISTRY_PASS      = local.entitled_registry_key
      DOCKER_USER_EMAIL         = var.entitled_registry_user_email
      DOCKER_USERNAME           = local.entitled_registry_user
      DOCKER_REGISTRY           = local.entitled_registry
      DOCKER_REGISTRY_PASS      = var.entitled_registry_key
    }
  }
}

data "external" "get_mq_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.create_mqsc_cmap,
    null_resource.install_mq
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_mq_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.mq.namespace
  }
}
