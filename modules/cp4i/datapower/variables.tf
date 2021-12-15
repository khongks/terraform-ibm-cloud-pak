variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Integration on the given cluster"
}

variable "cluster_config_path" {
  default     = "~/.kube/config"
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "storageclass" {
  default     = "ibmc-file-gold-gid"
  type        = string
  description = "Storage class to use.  If VPC, set to `portworx-rwx-gp3-sc` and make sure Portworx is set up on cluster"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "operator_namespace" {
  default     = "openshift-operators"
  description = "Namespace for operators for CP4I"
}

variable "cp4i_version" {
  default     = "2021.3.1"
  type        = string
  description = "Cloud Pak for Integration version"
}

variable "cp4i_channel_version" {
  default     = "v1.4"
  type        = string
  description = "Cloud Pak for Integration channel version"
}

variable "cp4i_license" {
  default     = "L-RJON-C5CSNH"
  type        = string
  description = "Cloud Pak for Integration license"
}

## DP

variable "dp" {
  description = "DP configuration variables"
  type = object({
    namespace = string
    release_name = string
    use = string
    storageclass = string
    channel_version = string
    license = string
    version = string
    profile = string
    test_and_monitor = bool
  })
}

locals {
  entitled_registry      = "cp.icr.io"
  entitled_registry_user = "cp"
  entitled_registry_key  = chomp(var.entitled_registry_key)
}
