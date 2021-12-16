#!/bin/sh

DIR=`dirname "$0"`
source ${DIR}/commons.sh

# Optional input parameters with default values:
SUB_NAME=${SUBSCRIPTION_NAME:-datapower-operator}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-operators}
DP_NAMESPACE=${DP_NAMESPACE:-dp}
DEBUG=${DEBUG:-false}
DOCKER_REGISTRY_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

create_namespace ${DP_NAMESPACE}
create_secret ibm-entitlement-key ${DP_NAMESPACE} ${DOCKER_REGISTRY} ${DOCKER_REGISTRY_USERNAME} ${DOCKER_REGISTRY_PASSWORD} ${DOCKER_REGISTRY_USER_EMAIL}
create_secret_for_userpass admin-credentials ${DP_NAMESPACE} "admin" "Passw0rd" 

echo "Deploying Subscription ${DP_SUBSCRIPTION_CONTENT}"
oc apply -f -<<EOF
${DP_SUBSCRIPTION_CONTENT}
EOF

wait_for_subscription ${OPERATOR_NAMESPACE} ${SUB_NAME}

echo "Deploying DataPower ${DP_CONTENT}"
oc apply -n ${DP_NAMESPACE} -f -<<EOF
${DP_CONTENT}
EOF

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

while true; do
  if ! STATUS_LONG=$(oc get DataPowerService -n ${DP_NAMESPACE} ${RELEASE_NAME} -ojson | jq -c -r '.status'); then
    echo 'Error getting status'
    exit 1
  fi

  echo $STATUS_LONG
  # STATUS=$(echo $STATUS_LONG | jq -c -r '.conditions[0].type')
  STATUS=$(echo $STATUS_LONG | jq -c -r '.phase')
  if [ "$STATUS" == "Running" ]; then
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



