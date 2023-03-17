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

if [ -z "$BQ_DATASET" ]; then
        echo "No BQ_DATASET variable set"
        exit
fi

#### This script assumes a dataset and table exists in BQ in the current Apigee project.

TOKEN=$(gcloud auth print-access-token)
SA_NAME=bq-api-service

echo "Installing apigeecli"
curl -s https://raw.githubusercontent.com/apigee/apigeecli/master/downloadLatest.sh | bash
export PATH=$PATH:$HOME/.apigeecli/bin

echo "Creating API Proxy Service Account and granting BQ roles to it"
gcloud iam service-accounts create $SA_NAME
gcloud projects add-iam-policy-binding "$PROJECT" \
    --member="serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataViewer" --condition=None

gcloud projects add-iam-policy-binding "$PROJECT" \
    --member="serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com" \
    --role="roles/bigquery.jobUser" --condition=None


echo "Creating and Deploying Apigee proxy proxy..."

if [[ "$OSTYPE" =~ ^linux ]]; then
    sed -i -e "s+BQ_DATASET+$BQ_DATASET+g" apiproxy/policies/AM-SetBQTableName.xml
fi

if [[ "$OSTYPE" =~ ^darwin ]]; then
    gsed -i -e "s+BQ_DATASET+$BQ_DATASET+g" apiproxy/policies/AM-SetBQTableName.xml
fi

REV=$(apigeecli apis create bundle -f apiproxy -n viewership-data-api  --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli apis deploy --wait --name viewership-data-api --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN" --sa ${SA_NAME}@"${PROJECT}".iam.gserviceaccount.com


echo " "
echo "All the Apigee artifacts are successfully deployed!"

echo " "
echo "Generate some calls with:"
echo "curl  https://$APIGEE_HOST/v1/views or https://$APIGEE_HOST/v1/views?orderBy=views "

