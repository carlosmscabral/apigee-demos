#!/bin/bash
# First argument should be org, second env.
# This depends on https://github.com/apigee/apigeecli to be installed

APIGEE_ORG=$1
APIGEE_ENV=$2

if [ -z "$1" ]
  then
    echo "org name is a mandatory parameter. Usage: 'import_config.sh {org} {env}'"
    exit 1
fi

if [ -z "$2" ]
  then
    echo "env name is a mandatory parameter. Usage: 'import_config.sh {org} {env}'"
    exit 1
fi

gcloud auth login 

apigeecli 2>&1 >/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "this script depends on apigeecli (https://github.com/apigee/apigeecli)"
  exit 1
fi

apigeecli apis get -n 004-External-Token-Verify -t $(gcloud auth print-access-token) -o $APIGEE_ORG >/dev/null 2>&1 
RESULT=$?
if [ $RESULT -ne 0 ]; then
    apigeecli apis create bundle  -t $(gcloud auth print-access-token) -f apiproxy -n 004-External-Token-Verify  -o $APIGEE_ORG
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "failed to import proxy"
        exit 1
    fi

    apigeecli apis deploy -o $APIGEE_ORG -t $(gcloud auth print-access-token) -e $APIGEE_ENV -v 1 -n 004-External-Token-Verify
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "failed to deploy proxy"
        exit 1
    fi    
fi