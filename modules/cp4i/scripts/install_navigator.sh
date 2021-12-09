#!/bin/sh

DIR=`dirname "$0"`
source ${DIR}/commons.sh

# Optional input parameters with default values:
SUB_NAME=${SUBSCRIPTION_NAME:-ibm-integration-platform-navigator}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-operators}
NAVIGATOR_NAMESPACE=${NAVIGATOR_NAMESPACE:-cp4i}
DOCKER_REGISTRY_USERNAME=${DOCKER_REGISTRY_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

create_namespace ${NAVIGATOR_NAMESPACE}
create_secret ibm-entitlement-key ${NAVIGATOR_NAMESPACE} ${DOCKER_REGISTRY} ${DOCKER_REGISTRY_USERNAME} ${DOCKER_REGISTRY_PASSWORD} ${DOCKER_REGISTRY_USER_EMAIL}

echo "Create Integration Navigator Subscription ${NAVIGATOR_SUBSCRIPTION_CONTENT}"
oc apply -f -<<EOF
${NAVIGATOR_SUBSCRIPTION_CONTENT}
EOF

wait_for_subscription ${OPERATOR_NAMESPACE} ${SUB_NAME}

wait_for_subscription ${OPERATOR_NAMESPACE} "ibm-common-service-operator-v3-ibm-operator-catalog-openshift-marketplace"

wait_for_subscription ${OPERATOR_NAMESPACE} "ibm-automation-core-v1.2-ibm-operator-catalog-openshift-marketplace"

echo "Deploying Integration Navigator ${NAVIGATOR_CONTENT}"
oc apply -f -<<EOF
${NAVIGATOR_CONTENT}
EOF

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

echo "NAVIGATOR_NAMESPACE: ${NAVIGATOR_NAMESPACE}"
echo "OPERATOR_NAMESPACE: ${OPERATOR_NAMESPACE}"

while true; do
  echo "oc get platformnavigator cp4i-navigator -n ${NAVIGATOR_NAMESPACE} -ojson"
  if ! STATUS_LONG=$(oc get platformnavigator cp4i-navigator -n ${NAVIGATOR_NAMESPACE} -ojson | jq -c -r '.status'); then
    echo 'Error getting status'
    exit 1
  fi

  echo $STATUS_LONG
  STATUS=$(echo $STATUS_LONG | jq -c -r '.conditions[0].type')

  if [ "$STATUS" == "Ready" ]; then
    break
  fi
  
  if [ "$STATUS" == "Failed" ]; then
    echo '=== Installation has failed ==='
    exit 1
  fi
  
  echo "Sleeping $SLEEP_TIME seconds..."
  sleep $SLEEP_TIME
  
  (( i++ ))
  if [ "$i" -eq "$RUN_LIMIT" ]; then
    echo 'Timed out'
    exit 1
  fi
done

route=$(oc get route -n ${NAVIGATOR_NAMESPACE} cp4i-navigator-pn -o json | jq -r .spec.host)
pass=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_password' | base64 -d)
user=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_username' | base64 -d)