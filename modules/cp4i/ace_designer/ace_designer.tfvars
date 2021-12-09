enable                          = true
#cluster_config_path             = "/root/auth/kubeconfig"
cluster_config_path             =  "/Users/khongks/.kube/config"
entitled_registry_user_email    = "kskhong@au1.ibm.com"
entitled_registry_key           = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzUyMjYxODgsImp0aSI6IjViODdiOGNhZWIwZDQzMmFiNmMwNDM5NGZkZGJkOWE2In0.IBzNGOK9KmWGTWGTo0cA27hJ4-z0XAWlS9Zo8apQqTo"
operator_namespace              = "openshift-operators"
ace_designer = {
    namespace             = "ace"
    release_name          = "ace-designer"
    use                   = "CloudPakForIntegrationNonProduction"
    replicas              = "1"
#    storageclass          = "ocs-storagecluster-cephfs"
    storageclass          = "ibmc-block-gold"
    channel_version       = "v2.1"
    license               = "L-APEH-C49KZH"
    version               = "12.0.2"
}