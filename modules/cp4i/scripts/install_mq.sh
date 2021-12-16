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

wait_for ${RELEASE_NAME} QueueManager ${MQ_NAMESPACE} "Running"

host=$(oc get route ${RELEASE_NAME}-ibm-mq-qm -n ${MQ_NAMESPACE} -ojson | jq -r '.spec.host')

echo ${host}
echo ${MQ_CCDT_CONTENT} | sed -e "s/{{HOST}}/${host}/g" | jq . > ${DIR}/../mq/test/ccdt.json