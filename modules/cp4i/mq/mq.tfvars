enable                          = true
cluster_config_path             =  "/Users/khongks/.kube/config"
# cluster_config_path             = "/root/auth/kubeconfig"
entitled_registry_user_email    = "kskhong@au1.ibm.com"
entitled_registry_key           = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzUyMjYxODgsImp0aSI6IjViODdiOGNhZWIwZDQzMmFiNmMwNDM5NGZkZGJkOWE2In0.IBzNGOK9KmWGTWGTo0cA27hJ4-z0XAWlS9Zo8apQqTo"
namespace                       = "cp4i"

## https://www.ibm.com/docs/en/ibm-mq/9.2?topic=mqibmcomv1beta1-licensing-reference
## requires ibm-mq-v1.6-ibm-operator-catalog-openshift-marketplace

mq = {
    namespace             = "cp4i"
    release_name          = "qm1"
    use                   = "NonProduction"
    replicas              = "1"
#     storageclass          = "ocs-storagecluster-cephfs"
    storageclass          = "ibmc-file-gold-gid"
    channel_version       = "v1.6"
    license               = "L-RJON-BZFQU2"
    version               = "9.2.3"
}