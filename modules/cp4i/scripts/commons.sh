#!/bin/bash

### Create namespace
function create_namespace() {
    namespace=$1

    if [ -z "${namespace}" ]; then
        echo "ERROR: missing namespace argument, make sure to pass namespace, ex: '-n mynamespace'"
        exit 1;
    fi

    status=$(oc get ns ${namespace} --ignore-not-found -ojson | jq -r .status.phase)
    if [[ ${status} != 'Active' ]]; then
    echo "Creating namespace ${namespace}"
    oc create namespace ${namespace}
    sleep 10
    else
    echo "Namespace ${namespace} found"
    fi
}

### Create secret
function create_secret() {
  secret_name=$1
  namespace=$2
  docker_registry=$3
  docker_registry_username=$4
  docker_registry_password=$5
  docker_registry_user_email=$6

  if [ -z "${secret_name}" ]; then
    echo "ERROR: missing secret_name"
    exit 1;
  fi
  if [ -z "${namespace}" ]; then
    echo "ERROR: missing namespace argument, make sure to pass namespace, ex: '-n mynamespace'"
    exit 1;
  fi
  if [ -z "${docker_registry}" ]; then
    echo "ERROR: missing docker_registry"
    exit 1;
  fi
  if [ -z "${docker_registry_username}" ]; then
    echo "ERROR: missing docker_registry_username"
    exit 1;
  fi
  if [ -z "${docker_registry_password}" ]; then
    echo "ERROR: missing docker_registry_password"
    exit 1;
  fi
  if [ -z "${docker_registry_user_email}" ]; then
    echo "ERROR: missing docker_registry_user_email"
    exit 1;
  fi

  found=$(oc get secret ${secret_name} -n ${namespace} --ignore-not-found -ojson | jq -r .metadata.name)
  if [[ ${found} != ${secret_name} ]]; then
    echo "Creating secret ${secret_name} on ${namespace} from entitlement key"
    # oc get secret ibm-entitlement-key -n ${namespace} --ignore-not-found
    oc create secret docker-registry ${secret_name} \
      --docker-server=${docker_registry} \
      --docker-username=${docker_registry_username} \
      --docker-password=${docker_registry_password} \
      --docker-email=${docker_registry_user_email} \
      --namespace=${namespace}
    sleep 10
  else
    echo "Secret ${secret_name} already created"
  fi
}

function create_secret_for_userpass() {
  secret_name=$1
  namespace=$2
  user=$3
  pass=$4

  if [ -z "${secret_name}" ]; then
    echo "ERROR: missing secret_name"
    exit 1;
  fi
  if [ -z "${namespace}" ]; then
    echo "ERROR: missing namespace argument, make sure to pass namespace, ex: '-n mynamespace'"
    exit 1;
  fi
  if [ -z "${user}" ]; then
    echo "ERROR: missing user"
    exit 1;
  fi
  if [ -z "${pass}" ]; then
    echo "ERROR: missing pass"
    exit 1;
  fi

  echo "oc create secret generic ${secret_name} -n ${namespace} --from-literal=password=${pass}"

  found=$(oc get secret ${secret_name} -n ${namespace} --ignore-not-found -ojson | jq -r .metadata.name)
  if [[ ${found} != ${secret_name} ]]; then
    echo "Creating secret ${secret_name} on ${namespace} from user pass"
    oc create secret generic ${secret_name} -n ${namespace} \
       --from-literal=password=${pass} 
    # oc get secret ibm-entitlement-key -n ${namespace} --ignore-not-found
    sleep 10
  else
    echo "Secret ${secret_name} already created"
  fi
}

### Patch default storage class
function patch_default_storageclass() {
  old_storageclass=$1
  new_storageclass=$2
  oc patch sc ${old_storageclass} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
  oc patch sc ${new_storageclass} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
  oc get sc
}

### Update pull secret
function update_pull_secret() {
  entitlementKey=$1

#  cat .dockerconfigjson | jq -r .auths

  oc extract secret/pull-secret -n openshift-config --keys=.dockerconfigjson --to=. --confirm
  cat .dockerconfigjson | jq . >  .dockerconfigjson.orig
  mv .dockerconfigjson.orig .dockerconfigjson

  entitlementKey_b64=$(echo $entitlementKey | base64)
  echo $entitlementKey_b64

  jq '.auths."cp.icr.io"={"auth":"{{entitlementKey_b64}}"}' .dockerconfigjson > .dockerconfigjson.new
  sed -i '' "s/{{entitlementKey_b64}}/${entitlementKey_b64}/" .dockerconfigjson.new

  cat .dockerconfigjson.new
  mv .dockerconfigjson.new .dockerconfigjson

  oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson
}

maxWaitTime=1800

### print a formatted time in minutes and seconds from the given input in seconds
function output_time {
  SECONDS=${1}
  if((SECONDS>59));then
    printf "%d minutes, %d seconds" $((SECONDS/60)) $((SECONDS%60))
  else
    printf "%d seconds" $SECONDS
  fi
}

### wait for a subscription to be successfully installed
### takes the name and the namespace as input
### waits for the specified maxWaitTime - if that is exceeded the subscriptions is deleted and it returns 1
function wait_for_subscription {
  NAMESPACE=${1}
  NAME=${2}

  echo "wait_for_subscription $NAMESPACE > $NAME"

  phase=""
  # inital time
  time=0
  # wait interval - how often the status is checked in seconds
  wait_time=5

  until [[ "$phase" == "Succeeded" ]]; do
    # csv=$(oc get subscription -n ${NAMESPACE} ${NAME} -o json | jq -r .status.currentCSV)
    csv=$(oc get csv -n openshift-operators  | grep ibm-apiconnect | awk '{print $1}')
    wait=0
    if [[ "$csv" == "null" ]]; then
      echo "INFO: Waited for $(output_time $time), not got csv for subscription"
      wait=1
    else
      phase=$(oc get csv -n ${NAMESPACE} $csv -o json | jq -r .status.phase)
      if [[ "$phase" != "Succeeded" ]]; then
        echo "INFO: Waited for $(output_time $time), csv not in Succeeded phase, currently: $phase"
        wait=1
      fi
    fi

    # if subscriptions hasn't succeeded yet: wait
    if [[ "$wait" == "1" ]]; then
      ((time=time+$wait_time))
      if [ $time -gt $maxWaitTime ]; then
        echo "ERROR: Failed after waiting for $((maxWaitTime/60)) minutes"
        # delete subscription after maxWaitTime has exceeded
        delete_subscription ${NAMESPACE} ${NAME}
        return 1
      fi

      # wait
      sleep $wait_time
    fi
  done
  echo "INFO: $NAME has succeeded"
}

function create_sub {
  SUBSCRIPTION_NAME=${1}
  NAMESPACE=${2}
  SUBSCRIPTION_CONTENT=${3}

echo ${SUBSCRIPTION_CONTENT}

  echo "create sub ${SUBSCRIPTION_NAME} ${NAMESPACE}"
  oc apply -f -<<EOF
${SUBSCRIPTION_CONTENT}
EOF

  # wait for it to succeed and retry if not
  wait_for_subscription ${NAMESPACE} ${SUBSCRIPTION_NAME}
  if [[ "$?" != "0"   ]]; then
    if [[ $RETRIED == true ]]
    then
      echo "ERROR: Failed to install subscription ${SUBSCRIPTION_NAME} after retrial, reinstalling now";
      retry true
    fi
    echo "INFO: retrying subscription ${SUBSCRIPTION_NAME}";
    create_sub ${SUBSCRIPTION_CONTENT}
  fi
}

# create a subscriptions and wait for it to be in succeeded state - if it fails: retry ones
# if it fails 2 times retry the whole installation
# param namespace: the namespace the subscription is created in
# param source: the catalog source of the operator
# param name: name of the subscription
# param channel: channel to be used for the subscription
# param retried: indicate whether this subscription has failed before and this is the retry
function create_subscription {
  NAMESPACE=${1}
  SOURCE=${2}
  NAME=${3}
  CHANNEL=${4}
  RETRIED=${5:-false};
  SOURCE_namespace=openshift-marketplace
  SUBSCRIPTION_NAME=${NAME}

  # create subscription itself
  cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ${SUBSCRIPTION_NAME}
  namespace: ${NAMESPACE}
spec:
  channel: ${CHANNEL}
  installPlanApproval: Automatic
  name: ${NAME}
  source: ${SOURCE}
  sourceNamespace: ${SOURCE_namespace}
EOF

  # wait for it to succeed and retry if not
  wait_for_subscription ${NAMESPACE} ${SUBSCRIPTION_NAME}
  if [[ "$?" != "0"   ]]; then
    if [[ $RETRIED == true ]]
    then
      echo "ERROR: Failed to install subscription ${NAME} after retrial, reinstalling now";
      retry true
    fi
    echo "INFO: retrying subscription ${NAME}";
    create_subscription ${NAMESPACE} ${SOURCE} ${NAME} ${CHANNEL} true
  fi
}

function wait_for () {
  OBJ_NAME=${1}
  OBJ_TYPE=${2}
  OBJ_NAMESPACE=${3}
  OBJ_READY_STATUS=$4

  echo "Waiting for [${OBJ_NAME}] of type [${OBJ_TYPE}] in namespace [${OBJ_NAMESPACE}] to be in [${OBJ_READY_STATUS}] status"

  SLEEP_TIME="60"
  RUN_LIMIT=200
  i=0

  while true; do

    if ! STATUS=$(oc get ${OBJ_TYPE} -n ${OBJ_NAMESPACE} ${OBJ_NAME} -ojson | jq -c -r '.status.phase'); then
      echo 'Error getting status'
      exit 1
    fi
    echo "Installation status: $STATUS"
    if [ "$STATUS" == ${OBJ_READY_STATUS} ]; then
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
}
