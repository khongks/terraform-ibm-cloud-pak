enable                          = true
cluster_config_path             =  "/Users/khongks/.kube/config"
# cluster_config_path             = "/root/auth/kubeconfig"
entitled_registry_user_email    = "kskhong@au1.ibm.com"
entitled_registry_key           = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzUyMjYxODgsImp0aSI6IjViODdiOGNhZWIwZDQzMmFiNmMwNDM5NGZkZGJkOWE2In0.IBzNGOK9KmWGTWGTo0cA27hJ4-z0XAWlS9Zo8apQqTo"
operator_namespace              = "openshift-operators"
ops_dashboard = {
    namespace             = "ops-dashboard"
    release_name          = "opsdash"
    file_storageclass     = "ibmc-file-gold-gid"
    block_storageclass    = "ibmc-block-gold"
    channel_version       = "v2.4"
    license               = "CP4I"
    version               = "2021.3.1-0"
}