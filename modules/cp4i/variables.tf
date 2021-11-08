variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Integration on the given cluster"
}

variable "cluster_config_path" {
  default     = "./.kube/config"
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
  default     = "kskhong@au1.ibm.com"
  description = "Docker email address"
}

variable "namespace" {
  default = "cp4i"
  description = "Namespace for Cloud Pak for Integration"
}

variable "cp4i_version" {
  default    = "2021.3.1"
  type       = string
  description = "Cloud Pak for Integration version"
}

variable "cp4i_license" {
  default     = "L-RJON-C5CSNH"
  type        = string
  description = "Cloud Pak for Integration license"
}

locals {
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  entitled_registry_key    = chomp(var.entitled_registry_key)
}
