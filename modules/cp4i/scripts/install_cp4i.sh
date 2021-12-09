#!/bin/sh

DIR=`dirname "$0"`
source ${DIR}/commons.sh

# Optional input parameters with default values:
SUB_NAME=${SUBSCRIPTION_NAME:-ibm-cp-integration}
OPERATOR_NAMESPACE=${NAMESPACE:-openshift-operators}
CP4I_SUBSCRIPTION_CONTENT=${CP4I_SUBSCRIPTION_CONTENT}
DEBUG=${DEBUG:-false}
DOCKER_USERNAME=${DOCKER_REGISTRY_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

echo "Deploying Catalog Option ${CATALOG_CONTENT}"
oc apply -f -<<EOF
${CATALOG_CONTENT}
EOF

oc get CatalogSource -n openshift-marketplace

patch_default_storageclass ${OLD_STORAGECLASS} ${STORAGECLASS}

update_pull_secret ${DOCKER_REGISTRY_PASSWORD}

echo "Create CP4I Subscription ${CP4I_SUBSCRIPTION_CONTENT}"
oc apply -f -<<EOF
${CP4I_SUBSCRIPTION_CONTENT}
EOF

wait_for_subscription ${OPERATOR_NAMESPACE} ${SUB_NAME}