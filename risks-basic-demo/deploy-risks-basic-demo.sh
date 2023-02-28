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

TOKEN=$(gcloud auth print-access-token)
HOME=$(pwd)

echo "Deploying backends..."
export BACKEND_NAME=apigee-legacy-risk
cd $HOME/backends/risk-legacy
source ./deploy.sh
export LEGACY_URL=$(gcloud run services describe $BACKEND_NAME --platform managed --region $REGION --format 'value(status.url)')


export BACKEND_NAME=apigee-new-risk
cd $HOME/backends/risk-new
source ./deploy.sh
export NEW_URL=$(gcloud run services describe $BACKEND_NAME --platform managed --region $REGION --format 'value(status.url)')

cd $HOME


echo "Installing apigeecli"
curl -s https://raw.githubusercontent.com/apigee/apigeecli/master/downloadLatest.sh | bash
export PATH=$PATH:$HOME/.apigeecli/bin

echo "Deploying Apigee artifacts..."

if [[ "$OSTYPE" =~ ^linux ]]; then
    sed -i -e "s+{{RISK_LEGACY_URL}}+$LEGACY_URL+g" apiproxy/targets/risk-legacy.xml
    sed -i -e "s+{{RISK_NEW_URL}}+$NEW_URL+g" apiproxy/targets/risk-new.xml
fi

if [[ "$OSTYPE" =~ ^darwin ]]; then
    gsed -i -e "s+{{RISK_LEGACY_URL}}+$LEGACY_URL+g" apiproxy/targets/risk-legacy.xml
    gsed -i -e "s+{{RISK_NEW_URL}}+$NEW_URL+g" apiproxy/targets/risk-new.xml
fi

echo "Importing and Deploying Apigee risks-basic-demo proxy..."
REV=$(apigeecli apis create bundle -f apiproxy  -n risks-basic-demo --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli apis deploy --wait --name risks-basic-demo --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Creating API Products"
apigeecli products create -o $PROJECT  -t $(gcloud auth print-access-token) --approval auto -n RiskStandardProduct --attrs=max-rate-per-min=5pm -e $APIGEE_ENV --opgrp products.json --displayname RiskStandardProduct
apigeecli products create -o $PROJECT  -t $(gcloud auth print-access-token) --approval auto -n RiskPremiumProduct --attrs=max-rate-per-min=20pm -e $APIGEE_ENV --opgrp products.json --displayname RiskPremiumProduct

echo "Creating Developers"
apigeecli developers create --user standarddev --email standarddev@acme.com --first Standard --last Dev --org "$PROJECT" --token "$TOKEN"
apigeecli developers create --user premiumdev --email premiumdev@acme.com --first Premium --last Dev --org "$PROJECT" --token "$TOKEN"

echo "Creating Developer Apps"
apigeecli apps create --name standard-app --email standarddev@acme.com --prods RiskStandardProduct --org "$PROJECT" --token "$TOKEN" --disable-check
apigeecli apps create --name premium-app --email premiumdev@acme.com --prods RiskPremiumProduct --org "$PROJECT" --token "$TOKEN" --disable-check

STANDARD_CLIENT_ID=$(apigeecli apps get --name standard-app --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."[0].credentials[0].consumerKey" -r)
export STANDARD_CLIENT_ID

PREMIUM_CLIENT_ID=$(apigeecli apps get --name premium-app --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."[0].credentials[0].consumerKey" -r)
export PREMIUM_CLIENT_ID

echo "Customizing POSTMAN collection"

if [[ "$OSTYPE" =~ ^linux ]]; then
    sed -i -e "s+{{premium_client_id}}+$PREMIUM_CLIEND_ID+g" risks-basic-demo.postman_collection.json
    sed -i -e "s+{{hostalias}}+$APIGEE_HOST+g" risks-basic-demo.postman_collection.json
    sed -i -e "s+{{standard_client_id}}+$STANDARD_CLIEND_ID+g" risks-basic-demo.postman_collection.json
    
fi

if [[ "$OSTYPE" =~ ^darwin ]]; then
    gsed -i -e "s+{{premium_client_id}}+$PREMIUM_CLIEND_ID+g" risks-basic-demo.postman_collection.json
    gsed -i -e "s+{{hostalias}}+$APIGEE_HOST+g" risks-basic-demo.postman_collection.json
    gsed -i -e "s+{{standard_client_id}}+$STANDARD_CLIEND_ID+g" risks-basic-demo.postman_collection.json
fi