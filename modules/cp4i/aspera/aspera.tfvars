enable                          = true
#cluster_config_path             = "/root/auth/kubeconfig"
cluster_config_path             =  "/Users/khongks/.kube/config"
entitled_registry_user_email    = "kskhong@au1.ibm.com"
entitled_registry_key           = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzUyMjYxODgsImp0aSI6IjViODdiOGNhZWIwZDQzMmFiNmMwNDM5NGZkZGJkOWE2In0.IBzNGOK9KmWGTWGTo0cA27hJ4-z0XAWlS9Zo8apQqTo"
operator_namespace              = "openshift-operators"
aspera = {
    namespace             = "aspera"
    release_name          = "hsts-service"
    use                   = "CloudPakForIntegrationNonProduction"
#    storageclass          = "ocs-storagecluster-cephfs"
    storageclass          = "ibmc-file-gold-gid"
    channel_version       = "v1.3"
    version               = "4.0.0"
    aspera_key            = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4NCjxsaWNlbnNlIHZlcnNpb249IjEiPg0KICA8IS0tIFZvaWQgaWYgbW9kaWZpZWQgLS0+DQogIDxwcm9kdWN0X2lkPjEwPC9wcm9kdWN0X2lkPg0KICA8Y3VzdG9tZXJfaWQ+MTwvY3VzdG9tZXJfaWQ+DQogIDxsaWNlbnNlX2lkPjc1OTEwPC9saWNlbnNlX2lkPg0KICA8ZXhwaXJhdGlvbl9kYXRlPjIwMjItMDEtMzE8L2V4cGlyYXRpb25fZGF0ZT4NCiAgPG1heGltdW1fYmFuZHdpZHRoPjEwMDAwMDA8L21heGltdW1fYmFuZHdpZHRoPg0KICA8YWNjb3VudHM+dW5saW1pdGVkPC9hY2NvdW50cz4NCiAgPHVuaXF1ZV9jb25jdXJyZW50X2xvZ2lucz51bmxpbWl0ZWQ8L3VuaXF1ZV9jb25jdXJyZW50X2xvZ2lucz4NCiAgPGNvbm5lY3RfZW5hYmxlZD55ZXM8L2Nvbm5lY3RfZW5hYmxlZD4NCiAgPG1vYmlsZV9lbmFibGVkPnllczwvbW9iaWxlX2VuYWJsZWQ+DQogIDxjYXJnb19lbmFibGVkPnllczwvY2FyZ29fZW5hYmxlZD4NCiAgPG5vZGVfZW5hYmxlZD55ZXM8L25vZGVfZW5hYmxlZD4NCiAgPGRyaXZlX2VuYWJsZWQ+eWVzPC9kcml2ZV9lbmFibGVkPg0KICA8aHR0cF9mYWxsYmFja19zZXJ2ZXJfZW5hYmxlZD55ZXM8L2h0dHBfZmFsbGJhY2tfc2VydmVyX2VuYWJsZWQ+DQogIDxncm91cF9jb25maWd1cmF0aW9uX2VuYWJsZWQ+eWVzPC9ncm91cF9jb25maWd1cmF0aW9uX2VuYWJsZWQ+DQogIDxzaGFyZWRfZW5kcG9pbnRzX2VuYWJsZWQ+eWVzPC9zaGFyZWRfZW5kcG9pbnRzX2VuYWJsZWQ+DQogIDxkZXNrdG9wX2d1aV9lbmFibGVkPnllczwvZGVza3RvcF9ndWlfZW5hYmxlZD4NCiAgPHN5bmMyPg0KICAgIDxlbmFibGVkPnllczwvZW5hYmxlZD4NCiAgICA8ZGlyZWN0aW9uPmJpZGk8L2RpcmVjdGlvbj4NCiAgICA8bWF4aW11bV9maWxlcz51bmxpbWl0ZWQ8L21heGltdW1fZmlsZXM+DQogIDwvc3luYzI+DQogIDx3YXRjaGZvbGRlcj4NCiAgICA8ZW5hYmxlZD55ZXM8L2VuYWJsZWQ+DQogICAgPGdyb3dpbmdfZmlsZXM+eWVzPC9ncm93aW5nX2ZpbGVzPg0KICAgIDxmaWxlX2xpc3RzPnllczwvZmlsZV9saXN0cz4NCiAgPC93YXRjaGZvbGRlcj4NCjwvbGljZW5zZT4NCj09U0lHTkFUVVJFPT0NCllHV290aXJyYTJ1ZndndlJocDRkYUVXRStBTlpzSE1LVXJpZjErL2xWcFVaeks4Y3RwTGRnMXl6MVRibQ0KZ3N2VVZvdm5MWWU4ZWoxbUdsZnhUUWZnZnhqZDJTelZqb0FzdzBJRHdGZk11TEJxeUsxSUhXOXRjVW5hDQp0QU43SnNsdEJ3eVV4SlhGSHFCcUlvZFp3MUIyMThnVWN2ejlhTkpraStrNTZ2ZFNld3hMQjYrc1pNVTINCmE0NWNBeGRmL2NKWVVtRFZ3RFRhZHBmY0FFMXNsU2JFajRlb1hLbW9aN3FtM1RVajNGT0wrZ0RLSnFVOA0KcWNkRkUyVnBQYWZXb0VXc3VGSjRQazArbHhmdzE2Und5QnpKU1BDODkzK0l6QXBTSCs1YU4veHl4N2hYDQo4emZYSWVxRlB1aHI4cFlRUmJkWjE4QVFoamNxdlRZMElHbHdzbXdGR1E9PQ0K"
}