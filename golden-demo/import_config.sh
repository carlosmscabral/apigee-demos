APIGEE_ORG=cabral-apigee

gcloud auth login

apigeecli devs import -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -f developers.json
apigeecli products import -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -f products.json
apigeecli apis create bundle -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -p apiproxy -n Risks-v2
apigeecli apps import -o $APIGEE_ORG  -t $(gcloud auth print-access-token) -d developers.json -f apps.json
