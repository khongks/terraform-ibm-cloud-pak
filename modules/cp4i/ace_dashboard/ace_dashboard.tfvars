enable                          = 0
cluster_config_path             = "/root/auth/kubeconfig"
entitled_registry_user_email    = "kskhong@au1.ibm.com"
entitled_registry_key           = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzUyMjYxODgsImp0aSI6IjViODdiOGNhZWIwZDQzMmFiNmMwNDM5NGZkZGJkOWE2In0.IBzNGOK9KmWGTWGTo0cA27hJ4-z0XAWlS9Zo8apQqTo"
namespace                       = "cp4i"

ace_dashboard = {
    namespace             = "cp4i"
    release_name          = "ace-dashboard"
    use                   = "CloudPakForIntegrationNonProduction"
    replicas              = "1"
    storageclass          = "ocs-storagecluster-cephfs"
    channel_version       = "v2.1"
    license               = "L-APEH-C49KZH"
    version               = "12.0.2.0"
}