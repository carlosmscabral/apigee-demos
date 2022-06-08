#!/bin/bash

# Assumes you have an active Apigee X org and eval up and running, and credentials
# for it. Also assumes you have installed https://github.com/srinandan/apigeecli 
# as well as the gcloud command line. 

APIGEE_ORG=ADD_YOUR_ORG_ID_HERE
APIGEE_ENV=ADD_YOUR_ENV
TOKEN=$(gcloud auth print-access-token)

apigeecli apis create bundle -z ./002-quota-per-error.zip -n 002-quota-per-error -o ${APIGEE_ORG} -t $TOKEN
apigeecli apis deploy -n 002-quota-per-error -o ${APIGEE_ORG} -t $TOKEN -e ${APIGEE_ENV} --rev 1

