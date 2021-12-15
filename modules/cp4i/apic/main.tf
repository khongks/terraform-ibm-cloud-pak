locals {
  apic_subscription_content = templatefile("${path.module}/../templates/subscription.yaml.tmpl", {
    sub_name             = "ibm-apiconnect"
    namespace            = var.operator_namespace
    channel_version      = var.apic.channel_version
    source               = "ibm-operator-catalog"
    source_namespace     = "openshift-marketplace"
  })
  apic_content = templatefile("${path.module}/../templates/apic/apic.yaml.tmpl", {
    namespace         = var.apic.namespace
    release_name      = var.apic.release_name
    use               = var.apic.use
    profile           = var.apic.profile
    storageclass      = var.apic.storageclass
    license           = var.apic.license
    version           = var.apic.version
    test_and_monitor  = var.apic.test_and_monitor
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_apic" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1          = sha1(var.apic.namespace)
    docker_params_sha1      = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    apic_subscription_sha1  = sha1(local.apic_subscription_content)
    apic_sha1               = sha1(local.apic_content)
  }

  provisioner "local-exec" {
    command     = "./install_apic.sh"
    working_dir = "${path.module}/../scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      OPERATOR_NAMESPACE            = var.operator_namespace
      APIC_NAMESPACE                = var.apic.namespace
      STORAGECLASS                  = var.apic.storageclass
      RELEASE_NAME                  = var.apic.release_name
      SUBSCRIPTION_NAME             = "ibm-apiconnect"
      APIC_SUBSCRIPTION_CONTENT     = local.apic_subscription_content
      APIC_CONTENT                  = local.apic_content
      DOCKER_REGISTRY_PASSWORD      = local.entitled_registry_key
      DOCKER_REGISTRY_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_REGISTRY_USERNAME      = local.entitled_registry_user
      DOCKER_REGISTRY               = local.entitled_registry
    }
  }
}

data "external" "get_apic_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_apic
  ]

  program = ["/bin/bash", "${path.module}/../scripts/get_apic_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.apic.namespace
    release_name = var.apic.release_name
  }
}
