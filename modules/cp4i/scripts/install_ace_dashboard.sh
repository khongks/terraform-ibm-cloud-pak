#!/bin/sh

DIR=`dirname "$0"`
source ${DIR}/commons.sh

# Optional input parameters with default values:
SUB_NAME=${SUBSCRIPTION_NAME:-ibm-appconnect}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-operators}
ACE_NAMESPACE=${ACE_NAMESPACE:-ace}
DEBUG=${DEBUG:-false}
DOCKER_REGISTRY_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

create_namespace ${ACE_NAMESPACE}
create_secret ibm-entitlement-key ${ACE_NAMESPACE} ${DOCKER_REGISTRY} ${DOCKER_REGISTRY_USERNAME} ${DOCKER_REGISTRY_PASSWORD} ${DOCKER_REGISTRY_USER_EMAIL}

echo "Deploying Subscription ${ACE_SUBSCRIPTION_CONTENT}"
oc apply -f -<<EOF
${ACE_SUBSCRIPTION_CONTENT}
EOF

wait_for_subscription ${OPERATOR_NAMESPACE} ${SUB_NAME}

echo "Deploying ACE dashboard ${ACE_DASHBOARD_CONTENT}"
oc apply -n ${ACE_NAMESPACE} -f -<<EOF
${ACE_DASHBOARD_CONTENT}
EOF

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

echo "ACE_NAMESPACE: ${ACE_NAMESPACE}"
echo "RELEASE_NAME: ${RELEASE_NAME}"

while true; do
  if ! STATUS_LONG=$(oc get dashboard -n ${ACE_NAMESPACE} ${RELEASE_NAME} -ojson | jq -c -r '.status'); then
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