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

apigeecli apis get -o $APIGEE_ORG -n Risks-v2 -t $(gcloud auth print-access-token) >/dev/null 2>&1 
RESULT=$?
if [ $RESULT -ne 0 ]; then
    apigeecli apis create bundle -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -f apiproxy -n Risks-v2
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "failed to import proxy"
        exit 1
    fi

    apigeecli apis deploy -o $APIGEE_ORG -t $(gcloud auth print-access-token) -e $APIGEE_ENV -v 1 -n Risks-v2
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "failed to deploy proxy"
        exit 1
    fi    
fi


apigeecli products create -o $APIGEE_ORG  -t $(gcloud auth print-access-token) --approval auto -n RiskStandardProduct --attrs=max-rate-per-min=5pm -e $APIGEE_ENV --opgrp products.json --displayname RiskStandardProduct
apigeecli products create -o $APIGEE_ORG  -t $(gcloud auth print-access-token) --approval auto -n RiskPremiumProduct --attrs=max-rate-per-min=20pm -e $APIGEE_ENV --opgrp products.json --displayname RiskPremiumProduct
apigeecli developers import -o $APIGEE_ORG -t $(gcloud auth print-access-token) -f developers.json
apigeecli apps create -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -n AppCorretorManuelPadaria -e manueldapadaria@google.com -p RiskStandardProduct
apigeecli apps keys create -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -n AppCorretorManuelPadaria -d manueldapadaria@google.com -p RiskStandardProduct -k appcorretormanuelpadariakey -r supersecretmanuel
apigeecli apps create -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -n AppCorretorFarialLimer -e farialimer@google.com -p RiskPremiumProduct
apigeecli apps keys create -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -n AppCorretorFarialLimer -d farialimer@google.com -p RiskPremiumProduct -k appcorretorfarialimerkey -r supersecretfarialimer
