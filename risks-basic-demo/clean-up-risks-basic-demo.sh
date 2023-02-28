#!/bin/bash

# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#echo "Enabling APIs..."
#gcloud services enable cloudbuild.googleapis.com

if [ -z "$PROJECT" ]; then
    echo "No PROJECT variable set"
    exit
fi

if [ -z "$APIGEE_ENV" ]; then
    echo "No APIGEE_ENV variable set"
    exit
fi

if [ -z "$APIGEE_HOST" ]; then
    echo "No APIGEE_HOST variable set"
    exit
fi

if [ -z "$REGION" ]; then
    echo "No REGION variable set"
    exit
fi

if [ -z "$LEGACY_BACKEND_NAME" ]; then
    echo "No LEGACY_BACKEND_NAME variable set"
    exit
fi

if [ -z "$NEW_BACKEND_NAME" ]; then
    echo "No NEW_BACKEND_NAME variable set"
    exit
fi

TOKEN=$(gcloud auth print-access-token)

echo "Installing apigeecli"
curl -s https://raw.githubusercontent.com/apigee/apigeecli/master/downloadLatest.sh | bash
export PATH=$PATH:$HOME/.apigeecli/bin

echo "Deleting Developer Apps"
DEVELOPER_ID=$(apigeecli developers get --email standarddev@acme.com --org "$PROJECT" --token "$TOKEN" --disable-check | jq .'developerId' -r)
apigeecli apps delete --id "$DEVELOPER_ID" --name standard-app --org "$PROJECT" --token "$TOKEN"

DEVELOPER_ID=$(apigeecli developers get --email premiumdev@acme.com --org "$PROJECT" --token "$TOKEN" --disable-check | jq .'developerId' -r)
apigeecli apps delete --id "$DEVELOPER_ID" --name premium-app --org "$PROJECT" --token "$TOKEN"

echo "Deleting Developer"
apigeecli developers delete --email standarddev@acme.com --org "$PROJECT" --token "$TOKEN"
apigeecli developers delete --email premiumdev@acme.com --org "$PROJECT" --token "$TOKEN"

echo "Deleting API Products"
apigeecli products delete --name RiskStandardProduct --org "$PROJECT" --token "$TOKEN"
apigeecli products delete --name RiskPremiumProduct --org "$PROJECT" --token "$TOKEN"

echo "Undeploying risks-basic-demo"
REV=$(apigeecli envs deployments get --env "$APIGEE_ENV" --org "$PROJECT" --token "$TOKEN" --disable-check | jq .'deployments[]| select(.apiProxy=="risks-basic-demo").revision' -r)
apigeecli apis undeploy --name risks-basic-demo --env "$APIGEE_ENV" --rev "$REV" --org "$PROJECT" --token "$TOKEN"

echo "Deleting proxy risks-basic-demo"
apigeecli apis delete --name risks-basic-demo --org "$PROJECT" --token "$TOKEN"

echo "Deleting backend Cloud Run services..."
gcloud config set run/region $REGION
for i in apigee-legacy-risk-backend apigee-legacy-new-backend
do
    gcloud run services delete $i --platform=managed
done