enable                          = true
cluster_config_path             =  "/Users/khongks/.kube/config"
# cluster_config_path             = "/root/auth/kubeconfig"
entitled_registry_user_email    = "kskhong@au1.ibm.com"
entitled_registry_key           = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzUyMjYxODgsImp0aSI6IjViODdiOGNhZWIwZDQzMmFiNmMwNDM5NGZkZGJkOWE2In0.IBzNGOK9KmWGTWGTo0cA27hJ4-z0XAWlS9Zo8apQqTo"
operator_namespace              = "openshift-operators"
## https://www.ibm.com/docs/en/ibm-mq/9.2?topic=mqibmcomv1beta1-licensing-reference
## requires ibm-mq-v1.6-ibm-operator-catalog-openshift-marketplace
mq = {
    namespace             = "mq"
    release_name          = "smallqm"
    use                   = "NonProduction"
#     storageclass          = "ocs-storagecluster-cephfs"
    storageclass          = "ibmc-block-gold"
    channel_version       = "v1.6"
    license               = "L-RJON-BZFQU2"
    version               = "9.2.3.0-r1"
    qmgr_name             = "SMALLQM"
    channel_name          = "SMALLQMCHL"
}