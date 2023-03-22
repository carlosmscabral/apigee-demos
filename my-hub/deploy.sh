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

# pre-reqs - assumes API Hub is already provisioned in PROJECT &
# registry tool https://github.com/apigee/registry/releases available locally

if [ -z "$PROJECT" ]; then
        echo "No PROJECT variable set"
        exit
fi

if [ -z "$REGION" ]; then
        echo "No REGION variable set"
        exit
fi


TOKEN=$(gcloud auth print-access-token)
SA_NAME=api-hub-mock-renderer

echo "Enabling APIs..."
gcloud services enable run.googleapis.com  --project="$PROJECT"
gcloud config set run/region $REGION
gcloud services enable cloudbuild.googleapis.com  --project="$PROJECT"

echo "Fetching Dockerfiles..."
git clone "https://github.com/apigee/registry-experimental"
cd registry-experimental/containers/registry-spec-renderer

echo "Creating Service Account for Cloud Run services and granting registry access to it"
gcloud iam service-accounts create $SA_NAME
gcloud projects add-iam-policy-binding "$PROJECT" \
    --member="serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com" \
    --role="roles/apigeeregistry.viewer" --condition=None

echo "Building the spec renderer image..."
gcloud builds submit --tag "gcr.io/$PROJECT/registry-spec-renderer" --project "$PROJECT"

echo "Deploying spec renderer to Cloud Run"
gcloud run deploy registry-spec-renderer --image="gcr.io/${PROJECT}/registry-spec-renderer" \
--platform=managed --project "${PROJECT}" --allow-unauthenticated --service-account=${SA_NAME}@${PROJECT}.iam.gserviceaccount.com

export RENDERER_URL=$(gcloud run services describe registry-spec-renderer --platform managed --region $REGION --format 'value(status.url)')

echo "Building the openapi mock image..."
cd ../registry-mock-server/openapi
gcloud builds submit --tag "gcr.io/$PROJECT/registry-openapi-mock" --project "$PROJECT"

echo "Deploying openapi mock to Cloud Run"
gcloud run deploy registry-openapi-mock --image="gcr.io/${PROJECT}/registry-openapi-mock" \
--platform=managed --project "${PROJECT}" --allow-unauthenticated --service-account=${SA_NAME}@${PROJECT}.iam.gserviceaccount.com

export OPENAPI_MOCK_ENDPOINT=$(gcloud run services describe registry-openapi-mock --platform managed --region $REGION --format 'value(status.url)')

echo "Building the graphql mock image..."
cd ../graphql
gcloud builds submit --tag "gcr.io/$PROJECT/registry-graphql-mock" --project "$PROJECT"

echo "Deploying openapi mock to Cloud Run"
gcloud run deploy registry-graphql-mock --image="gcr.io/${PROJECT}/registry-graphql-mock" \
--platform=managed --project "${PROJECT}" --allow-unauthenticated --service-account=${SA_NAME}@${PROJECT}.iam.gserviceaccount.com

export GRAPHQL_MOCK_ENDPOINT=$(gcloud run services describe registry-graphql-mock --platform managed --region $REGION --format 'value(status.url)')

echo "Updating the environment variables for the renderer service"
gcloud run services update registry-spec-renderer --update-env-vars OPENAPI_MOCK_ENDPOINT=$OPENAPI_MOCK_ENDPOINT,GRAPHQL_MOCK_ENDPOINT=$GRAPHQL_MOCK_ENDPOINT

echo "Installing registry tool"
curl -L https://raw.githubusercontent.com/apigee/registry/main/downloadLatest.sh | sh -
export PATH=$PATH:$HOME/.registry/bin

echo "Configuring registry tool (assumes registry is installed)"
registry config configurations create config-$PROJECT \
    --registry.address=apigeeregistry.googleapis.com:443 \
    --registry.insecure=0 \
    --registry.project=$PROJECT \
    --registry.location=global

registry config set token-source 'gcloud auth print-access-token'

echo "Updating API definitions with new URLs for deployment"
cd ../../../..
if [[ "$OSTYPE" =~ ^linux ]]; then
    sed -i -e "s/GCP_PROJECT/$PROJECT/g" risksapi.yaml 
    sed -i -e "s+RENDERER_URL+$RENDERER_URL+g" risksapi.yaml
fi

if [[ "$OSTYPE" =~ ^darwin ]]; then
    gsed -i -e "s/GCP_PROJECT/$PROJECT/g" risksapi.yaml 
    gsed -i -e "s+RENDERER_URL+$RENDERER_URL+g" risksapi.yaml
fi


registry apply -f . \
--parent=projects/$PROJECT/locations/global

registry rpc create-api-deployment \
 --api_deployment.display_name=sample \
 --api_deployment.endpoint_uri="https://petstore.swagger.io/v2" \
--api_deployment.api_spec_revision="projects/$PROJECT/locations/global/apis/openapi-sample/versions/v1/specs/petstore.json" \
--api_deployment.external_channel_uri="$RENDERER_URL/render/projects/$PROJECT/locations/global/apis/openapi-sample/deployments/sample" \
--api_deployment.name=projects/$PROJECT/locations/global/apis/openapi-sample/deployments/sample \
--api_deployment.name=projects/$PROJECT/locations/global/apis/openapi-sample/deployments/sample \
 --api_deployment_id=sample \
 --api_deployment.labels="apihub-gateway=apihub-unmanaged" \
 --api_deployment.annotations="apihub-external-channel-name=View Documentation" \
--parent=projects/$PROJECT/locations/global/apis/openapi-sample 


registry rpc create-api-deployment \
 --api_deployment.display_name=sample \
--api_deployment.api_spec_revision="projects/$PROJECT/locations/global/apis/graphql-sample/versions/v1/specs/schemagraphql" \
--api_deployment.external_channel_uri="$RENDERER_URL/render/projects/$PROJECT/locations/global/apis/graphql-sample/deployments/sample" \
--api_deployment.name=projects/$PROJECT/locations/global/apis/graphql-sample/deployments/sample \
 --api_deployment_id=sample \
 --api_deployment.endpoint_uri="https://swapi-graphql.netlify.app/.netlify/functions/index" \
 --api_deployment.labels="apihub-gateway=apihub-unmanaged" \
 --api_deployment.annotations="apihub-external-channel-name=View Documentation" \
--parent=projects/$PROJECT/locations/global/apis/graphql-sample 