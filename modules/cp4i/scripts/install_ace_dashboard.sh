#!/bin/sh

# Optional input parameters with default values:
NAMESPACE=${NAMESPACE:-cp4i}
DEBUG=${DEBUG:-false}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

JOB_NAME="cloud-installer"
WAITING_TIME=5

# echo "Waiting for Ingress domain to be created"
# while [[ -z $(oc get route -n openshift-ingress router-default -o jsonpath='{.spec.host}' 2>/dev/null) ]]; do
#   sleep $WAITING_TIME
# done

status=$(oc get ns ${NAMESPACE} --ignore-not-found -ojson | jq -r .status.phase)
if [[ ${status} != 'Active' ]]; then
  echo "Creating namespace ${NAMESPACE}"
  oc create namespace ${NAMESPACE}
  sleep 10
else
  echo "Namespace ${NAMESPACE} found"
fi

create_secret() {
  secret_name=$1
  namespace=$2
  link=$3

  found=$(oc get secret ${secret_name} -n ${NAMESPACE} --ignore-not-found -ojson | jq -r .metadata.name)
  if [[ ${found} != ${secret_name} ]]; then
    echo "Creating secret ${secret_name} on ${NAMESPACE} from entitlement key"
    oc get secret ibm-entitlement-key -n ${NAMESPACE} --ignore-not-found
    oc create secret docker-registry ${secret_name} \
      --docker-server=${DOCKER_REGISTRY} \
      --docker-username=${DOCKER_USERNAME} \
      --docker-password=${DOCKER_REGISTRY_PASS} \
      --docker-email=${DOCKER_USER_EMAIL} \
      --namespace=${namespace}
    sleep 10
  else
    echo "Secret ${secret_name} already created"
  fi
}

create_secret ibm-entitlement-key default
create_secret ibm-entitlement-key openshift-operators
create_secret ibm-entitlement-key $NAMESPACE


echo "Deploying Subscription ${ACE_SUBSCRIPTION_CONTENT}"
oc apply -f -<<EOF
${ACE_SUBSCRIPTION_CONTENT}
EOF

echo "Waiting 10 minutes for operators to install..."
sleep 600

echo "Deploying ACE dashboard ${ACE_DASHBOARD_CONTENT}"
oc apply -n ${NAMESPACE} -f -<<EOF
${ACE_DASHBOARD_CONTENT}
EOF

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

while true; do
  if ! STATUS_LONG=$(oc -n ${NAMESPACE} get dashboard ${RELEASE_NAME} -ojson | jq -c -r '.status'); then
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