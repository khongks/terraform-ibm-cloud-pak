#!/bin/sh

DIR=`dirname "$0"`
source ${DIR}/commons.sh

# Optional input parameters with default values:
SUB_NAME=${SUBSCRIPTION_NAME:-ibm-aspera-hsts-operator}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-operators}
ASPERA_NAMESPACE=${ASPERA_NAMESPACE:-aspera}
DEBUG=${DEBUG:-false}
DOCKER_REGISTRY_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

create_namespace ${ASPERA_NAMESPACE}
create_secret ibm-entitlement-key ${ASPERA_NAMESPACE} ${DOCKER_REGISTRY} ${DOCKER_REGISTRY_USERNAME} ${DOCKER_REGISTRY_PASSWORD} ${DOCKER_REGISTRY_USER_EMAIL}

echo "Deploying Subscription ${ASPERA_SUBSCRIPTION_CONTENT}"
oc apply -f -<<EOF
${ASPERA_SUBSCRIPTION_CONTENT}
EOF

wait_for_subscription ${OPERATOR_NAMESPACE} ${SUB_NAME}

echo "Deploying IbmAsperaHsts ${ASPERA_CONTENT}"
oc apply -n ${ASPERA_NAMESPACE} -f -<<EOF
${ASPERA_CONTENT}
EOF

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

while true; do
  if ! STATUS_LONG=$(oc get IbmAsperaHsts -n ${ASPERA_NAMESPACE} ${RELEASE_NAME} -ojson | jq -c -r '.status'); then
    echo 'Error getting status'
    exit 1
  fi

  echo $STATUS_LONG
  # STATUS=$(echo $STATUS_LONG | jq -c -r '.conditions[0].type')
  STATUS=$(echo $STATUS_LONG | jq -c -r '.phase')
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



