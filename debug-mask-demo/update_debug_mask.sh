#!/bin/bash

ORG=prod-project-242716
ENV=eval
TOKEN=$(gcloud auth print-access-token)

curl "https://apigee.googleapis.com/v1/organizations/${ORG}/environments/${ENV}/debugmask" \
  -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-type: application/json" \
  -d \
  '{
    "variables": [
      "request.queryparam.char"
    ]
   }'

#To remove mask, run this:

#curl "https://apigee.googleapis.com/v1/organizations/${ORG}/environments/${ENV}/debugmask?replaceRepeatedFields=true" \
#  -X PATCH \
#  -H "Authorization: Bearer $TOKEN" \
#  -H "Content-type: application/json" \
#  -d \
#  '{}'