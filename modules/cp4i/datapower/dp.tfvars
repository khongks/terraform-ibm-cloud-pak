enable                          = true
#cluster_config_path             = "/root/auth/kubeconfig"
cluster_config_path             =  "/Users/khongks/.kube/config"
entitled_registry_user_email    = "kskhong@au1.ibm.com"
entitled_registry_key           = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzUyMjYxODgsImp0aSI6IjViODdiOGNhZWIwZDQzMmFiNmMwNDM5NGZkZGJkOWE2In0.IBzNGOK9KmWGTWGTo0cA27hJ4-z0XAWlS9Zo8apQqTo"
operator_namespace              = "openshift-operators"
dp = {
    namespace             = "dp"
    release_name          = "datapower"
    use                   = "nonproduction"
#    storageclass          = "ocs-storagecluster-cephfs"
    storageclass          = "ibmc-block-gold"
    channel_version       = "v1.4"
    license               = "L-RJON-C2XKPU"
    version               = "10.0-cd"
}