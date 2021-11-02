provider "ibm" {
  region     = var.region
  version    = "~> 1.12"
}

//terraform {
//  required_version = ">=0.13"
//  required_providers {
//    ibm = {
//      source = "IBM-Cloud/ibm"
//      version    = "~> 1.12"
//    }
//  }
//}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

# go in the example
resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${local.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = local.cluster_config_path
  admin             = false
  network           = false
}

module "cp4ba" {
//  source = ".git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/cp4ba"
//  source = ".git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/joel_cp4ba_edited/modules/cp4ba_edited"
  source = "../.."
  enable = true

  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  # ---- IBM Cloud API Key ----
  # ibmcloud_api_key       = var.ibmcloud_api_key

  # ---- Cluster ----
//  cluster_config_path           = local.cluster_config_path

  # ---- Platform ----
  CP4BA_PROJECT_NAME            = var.cp4ba_project_name

  # ---- Registry Images ----
  ENTITLED_REGISTRY_EMAIL       = var.entitled_registry_user
  ENTITLED_REGISTRY_KEY         = var.entitlement_key
  DOCKER_SERVER                 = local.docker_server
  DOCKER_USERNAME               = local.docker_username

  # ------- FILES ASSIGNMENTS --------
//  CP4BA_STORAGE_CLASS_FILE      = local.cp4ba_storage_class_file
//  OPERATOR_PVC_FILE             = local.pvc_file
//  CATALOG_SOURCE_FILE           = local.catalog_source_file
//  CP4BA_SUBSCRIPTION_CONTENT    = local.cp4ba_subscription_content
//  CP4BA_DEPLOYMENT_CONTENT      = local.cp4ba_deployment_content
//  SECRETS_CONTENT               = local.secrets_content

//  # ---- Platform ----
//  CP4BA_PROJECT_NAME       = "cp4ba"
//  ENTITLED_REGISTRY_EMAIL  = var.entitled_registry_user
//  ENTITLED_REGISTRY_KEY    = var.entitlement_key
//
//  # ----- DB2 Settings -----
//  db2_host_name           = var.db2_host_name
//  db2_host_port           = var.db2_host_port
//  db2_admin               = var.db2_admin
//  db2_user                = var.db2_user
//  db2_password            = var.db2_password
//
//  # ----- LDAP Settings -----
//  ldap_admin              = var.ldap_admin
//  ldap_password           = var.ldap_password
//  ldap_host_ip            = var.ldap_host_ip
}
