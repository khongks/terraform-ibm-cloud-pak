#!/bin/sh

DIR=`dirname "$0"`
source ${DIR}/commons.sh

# Optional input parameters with default values:
SUB_NAME=${SUBSCRIPTION_NAME:-ibm-apiconnect}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-operators}
APIC_NAMESPACE=${APIC_NAMESPACE:-apic}
DEBUG=${DEBUG:-false}
DOCKER_REGISTRY_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

create_namespace ${APIC_NAMESPACE}
create_secret ibm-entitlement-key ${APIC_NAMESPACE} ${DOCKER_REGISTRY} ${DOCKER_REGISTRY_USERNAME} ${DOCKER_REGISTRY_PASSWORD} ${DOCKER_REGISTRY_USER_EMAIL}

echo "Deploying Subscription ${APIC_SUBSCRIPTION_CONTENT}"
oc apply -f -<<EOF
${APIC_SUBSCRIPTION_CONTENT}
EOF

wait_for_subscription ${OPERATOR_NAMESPACE} ${SUB_NAME}

echo "Deploying APIC ${APIC_CONTENT}"
oc apply -n ${APIC_NAMESPACE} -f -<<EOF
${APIC_CONTENT}
EOF

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

while true; do
  if ! STATUS_LONG=$(oc get APIConnectCluster -n ${APIC_NAMESPACE} ${RELEASE_NAME} -ojson | jq -c -r '.status'); then
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



