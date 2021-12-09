locals {
  # These are the the yamls that will be pulled from the ./files  these will be used to start hte operator
  catalog_content = templatefile("${path.module}/templates/catalog.yaml.tmpl", {
    namespace = var.operator_namespace
  })

  cp4i_subscription_content = templatefile("${path.module}/templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-cp-integration"
    namespace            = var.operator_namespace
    channel_version      = var.cp4i_channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })
  cp4i_operatorgroup_content = templatefile("${path.module}/templates/operatorgroup.yaml.tmpl", {
    name                 = "ibm-cp-integration"
    namespace            = var.operator_namespace
  })

  navigator_subscription_content = templatefile("${path.module}/templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-integration-platform-navigator"
    namespace            = var.operator_namespace
    channel_version      = var.platform_nav.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })

  navigator_content = templatefile("${path.module}/templates/navigator.yaml.tmpl", {
    namespace             = var.platform_nav.namespace
    storageclass          = var.storageclass
    cp4i_license          = var.cp4i_license
    cp4i_version          = var.cp4i_version
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4i" {
  count = var.enable ? 1 : 0

  triggers = {
    operator_namespace_sha1     = sha1(var.operator_namespace)
    docker_params_sha1          = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    catalog_sha1                = sha1(local.catalog_content)
    subscription_sha1           = sha1(local.cp4i_subscription_content)
  }

  provisioner "local-exec" {
    command     = "./install_cp4i.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      SUBSCRIPTION_NAME             = "ibm-cp-integration"
      KUBECONFIG                    = var.cluster_config_path
      OPERATOR_NAMESPACE            = var.operator_namespace
      STORAGECLASS                  = var.storageclass
      OLD_STORAGECLASS              = var.old_storageclass
      CATALOG_CONTENT               = local.catalog_content
      CP4I_SUBSCRIPTION_CONTENT     = local.cp4i_subscription_content
      CP4I_OPERATORGROUP_CONTENT    = local.cp4i_operatorgroup_content
      DOCKER_REGISTRY_PASSWORD      = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME      = local.entitled_registry_user
      DOCKER_REGISTRY               = local.entitled_registry
    }
  }
}

resource "null_resource" "install_navigator" {
  count = var.enable ? 1 : 0

  triggers = {
    operator_namespace_sha1         = sha1(var.operator_namespace)
    docker_params_sha1              = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    navigator_sha1                  = sha1(local.navigator_content)
  }

  depends_on = [
    null_resource.install_cp4i
  ]

  provisioner "local-exec" {
    command     = "./install_navigator.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      SUBSCRIPTION_NAME               = "ibm-integration-platform-navigator"
      KUBECONFIG                      = var.cluster_config_path
      OPERATOR_NAMESPACE              = var.operator_namespace
      NAVIGATOR_NAMESPACE             = var.platform_nav.namespace
      RELEASE_NAME                    = var.platform_nav.release_name
      STORAGECLASS                    = var.storageclass
      NAVIGATOR_SUBSCRIPTION_CONTENT  = local.navigator_subscription_content
      NAVIGATOR_CONTENT               = local.navigator_content
      DOCKER_REGISTRY_PASSWORD        = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL      = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME        = local.entitled_registry_user
      DOCKER_REGISTRY                 = local.entitled_registry
    }
  }
}


data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_navigator
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.platform_nav.namespace
  }
}
