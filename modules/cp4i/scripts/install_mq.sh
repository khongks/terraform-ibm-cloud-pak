#!/bin/sh

DIR=`dirname "$0"`
source ${DIR}/commons.sh

# Optional input parameters with default values:
SUB_NAME=${SUBSCRIPTION_NAME:-ibm-mq}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-operators}
MQ_NAMESPACE=${MQ_NAMESPACE:-mq}
RELEASE_NAME=${RELEASE_NAME:-smallqm}
DEBUG=${DEBUG:-false}
DOCKER_REGISTRY_USERNAME=${DOCKER_REGISTRY_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

create_namespace ${MQ_NAMESPACE}
create_secret ibm-entitlement-key ${MQ_NAMESPACE} ${DOCKER_REGISTRY} ${DOCKER_REGISTRY_USERNAME} ${DOCKER_REGISTRY_PASSWORD} ${DOCKER_REGISTRY_USER_EMAIL}

echo "Deploying Subscription ${MQ_SUBSCRIPTION_CONTENT}"
oc apply -f -<<EOF
${MQ_SUBSCRIPTION_CONTENT}
EOF

wait_for_subscription ${OPERATOR_NAMESPACE} ${SUB_NAME}

echo "Deploying MQ ${MQ_CONTENT}"
oc apply -n ${MQ_NAMESPACE} -f -<<EOF
${MQ_CONTENT}
EOF

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

while true; do

  if ! STATUS=$(oc get QueueManager -n ${MQ_NAMESPACE} ${RELEASE_NAME} -ojson | jq -c -r '.status.phase'); then
    echo 'Error getting status'
    exit 1
  fi
  echo "Installation status: $STATUS"
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
