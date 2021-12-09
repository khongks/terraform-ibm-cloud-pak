#!/bin/bash

# echo "NAMESPACE: ${NAMESPACE}"
NAMESPACE=${NAMESPACE:-cp4i}
RELEASE_NAME=${RELEASE_NAME:-ace-designer}

eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.namespace)"')"

# Obtains the credentials and endpoints for the installed CP4I Dashboard
results() {
  console_url_address=$1
  password=$2
  username=$3

  # NOTE: The credentials are static and defined by the installer, in the future this
  # may not be the case.
  # username="admin"

  jq -n \
    --arg endpoint "$console_url_address" \
    --arg username "$username" \
    --arg password "$password" \
    '{ "endpoint": $endpoint, "username": $username, "password": $password }'

  exit 0
}

# POD=$(oc get pods -n cpd-meta-ops | grep ibm-cp-data-operator | awk '{print $1}')
# control_plane_log=$(oc logs -n cpd-meta-ops $POD | sed 's/[[:cntrl:]]\[[0-9;]*m//g' | tail -20)
# address=$(echo $control_plane_log | sed -n 's#.*\(https*://[^"]*\).*#\1#p')
route=$(oc get route -n ${NAMESPACE} ${RELEASE_NAME}-ui -o json | jq -r .spec.host)
pass=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_password' | base64 -d)
user=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_username' | base64 -d)

# echo $route
results "${route}" "${pass}" "${user}"
