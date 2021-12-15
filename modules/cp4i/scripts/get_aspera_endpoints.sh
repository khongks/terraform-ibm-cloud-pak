#!/bin/bash

NAMESPACE=${NAMESPACE:-aspera}
RELEASE_NAME=${RELEASE_NAME:-hsts_service}

eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.namespace)"')"

# Obtains the credentials and endpoints for the installed CP4I Dashboard
results() {
  cloud_admin_ui=$1
  api_manager_ui=$2
  consumer_api=$3
  platform_api=$4
  password=$5
  username=$6

  # NOTE: The credentials are static and defined by the installer, in the future this
  # may not be the case.
  # username="admin"

  jq -n \
    --arg cloud_admin_ui "$cloud_admin_ui" \
    --arg api_manager_ui "$api_manager_ui" \
    --arg consumer_api "$consumer_api" \
    --arg platform_api "$platform_api" \
    --arg username "$username" \
    --arg password "$password" \
    '{ "cloud_admin_ui": $cloud_admin_ui, "api_manager_ui": $api_manager_ui, "consumer_api": $consumer_api, "platform_api": $platform_api, "username": $username, "password": $password }'
  exit 0
}

cloud_admin_ui=https://$(oc get route -n ${NAMESPACE} ${RELEASE_NAME}-mgmt-admin -o json | jq -r .spec.host)
api_manager_ui=https://$(oc get route -n ${NAMESPACE} ${RELEASE_NAME}-mgmt-api-manager -o json | jq -r .spec.host)
consumer_api=https://$(oc get route -n ${NAMESPACE} ${RELEASE_NAME}-mgmt-consumer-api -o json | jq -r .spec.host)
platform_api=https://$(oc get route -n ${NAMESPACE} ${RELEASE_NAME}-mgmt-platform-api -o json | jq -r .spec.host)
pass=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_password' | base64 -d)
user=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_username' | base64 -d)

results "${cloud_admin_ui}" "${api_manager_ui}" "${consumer_api}" "${platform_api}" "${pass}" "${user}"