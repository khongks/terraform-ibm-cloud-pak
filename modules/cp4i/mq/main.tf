locals {
  mq_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-mq"
    namespace            = var.operator_namespace
    channel_version      = var.mq.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })

  mq_content = templatefile("${path.module}/../templates/mq/smallqm.yaml.tmpl", {
    namespace       = var.mq.namespace
    release_name    = var.mq.release_name
    use             = var.mq.use
    storageclass    = var.mq.storageclass
    license         = var.mq.license
    version         = var.mq.version
    qmgr_name       = var.mq.qmgr_name
    channel_name    = var.mq.channel_name
    channel_name_lower = lower(var.mq.channel_name)
  })

  mq_ccdt_content = templatefile("${path.module}/../templates/mq/ccdt.json.tmpl", {
    qmgr_name            = var.mq.qmgr_name
    channel_name         = var.mq.channel_name
    host                 = "{{HOST}}"
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_mq" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1        = sha1(var.mq.namespace)
    docker_params_sha1    = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    mq_subscription_sha1  = sha1(local.mq_subscription_content)
    mq_content_sha1       = sha1(local.mq_content)
  }

  provisioner "local-exec" {
    command     = "./install_mq.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                 = var.cluster_config_path
      OPERATOR_NAMESPACE         = var.operator_namespace
      MQ_NAMESPACE               = var.mq.namespace
      STORAGECLASS               = var.mq.storageclass
      RELEASE_NAME               = var.mq.release_name
      SUBSCRIPTION_NAME          = "ibm-mq"
      MQ_SUBSCRIPTION_CONTENT    = local.mq_subscription_content
      MQ_CONTENT                 = local.mq_content
      MQ_CCDT_CONTENT            = local.mq_ccdt_content
      DOCKER_REGISTRY_PASSWORD   = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME   = local.entitled_registry_user
      DOCKER_REGISTRY            = local.entitled_registry
    }
  }
}

data "external" "get_mq_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_mq
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_mq_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.mq.namespace
    release_name = var.mq.release_name
  }
}
