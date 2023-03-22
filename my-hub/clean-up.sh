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

echo "Deleting APIs from API Hub..."

for i in risksapi openapi-sample grpc-sample graphql-sample asyncapi-sample
do
    registry delete apis/$i -f
done

echo "Deleting Renderer and Mock services..."
gcloud config set run/region $REGION
for i in registry-spec-renderer registry-openapi-mock registry-graphql-mock
do
    gcloud run services delete $i --platform=managed
done

echo "Deleting service account"
gcloud iam service-accounts delete ${SA_NAME}@"${PROJECT}".iam.gserviceaccount.com