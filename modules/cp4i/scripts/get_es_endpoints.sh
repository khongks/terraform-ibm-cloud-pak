#!/bin/bash

NAMESPACE=${NAMESPACE:-es}
RELEASE_NAME=${RELEASE_NAME:-es-dev}

eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.namespace)"')"

# Obtains the credentials and endpoints for the installed CP4I Dashboard
results() {
  es_ui_endpoint=$1
  es_bootstrap_endpoint=$2
  password=$3
  username=$4

  # NOTE: The credentials are static and defined by the installer, in the future this
  # may not be the case.
  # username="admin"

  jq -n \
    --arg es_ui_endpoint "$es_ui_endpoint" \
    --arg es_bootstrap_endpoint "$es_bootstrap_endpoint" \
    --arg username "$username" \
    --arg password "$password" \
    '{ "es_ui_endpoint": $es_ui_endpoint, "es_bootstrap_endpoint": $es_bootstrap_endpoint, "username": $username, "password": $password }'
  exit 0
}

es_ui_endpoint=https://$(oc get route -n ${NAMESPACE} ${RELEASE_NAME}-ibm-es-ui -o json | jq -r .spec.host)
es_bootstrap_endpoint=https://$(oc get route -n ${NAMESPACE} ${RELEASE_NAME}-kafka-bootstrap -o json | jq -r .spec.host)
pass=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_password' | base64 -d)
user=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_username' | base64 -d)

results "${es_ui_endpoint}" "${es_bootstrap_endpoint}" "${pass}" "${user}"