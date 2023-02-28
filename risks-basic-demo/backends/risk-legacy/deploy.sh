#!/bin/bash

echo "Building the image..."
gcloud builds submit --tag "gcr.io/$PROJECT/${BACKEND_NAME}" --project "$PROJECT"

echo "Deploying to Cloud Run"
gcloud run deploy ${BACKEND_NAME}-backend --image="gcr.io/${PROJECT}/${BACKEND_NAME}" \
--platform=managed --region=${REGION} --project "${PROJECT}" --allow-unauthenticated