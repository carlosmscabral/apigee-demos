# API Hub demo

Sample script for demoing API Hub, Spec Renderers and Mock Servers.
Derives heavily from what is the [Registry-Experimental](https://github.com/apigee/registry-experimental) repo.

## Guidelines

This script assumes you have already provisioned API Hub in your GCP Project.
Make sure you are Project Owner in terms of IAM permissions.
Edit the variables in the `env.sh` files and source it.

```bash
source ./env.sh
```

And deploy with 

```bash
source ./deploy
```

For cleanup - 

```bash
source ./clean-up.sh
```

This script creates 3 Cloud Run services (one Spec Renderer that points to 2 Mock Servers for OpenAPI and GraphQL)
It also deploys a few APIs to API Hub.
The Risks API gets its deployment information updated to point to the Spec Renderer service, which will fetch the spec from API Hub, render it and point traffic towards the Mock Open API Server. The GraphQL API in Hub has similar approach.

## Screencast

[![Alt text](https://img.youtube.com/vi/ep7h_tGHtiw/0.jpg)](https://www.youtube.com/watch?v=ep7h_tGHtiw)

## Prerequisites
1. [Provision Apigee X](https://cloud.google.com/apigee/docs/api-platform/get-started/provisioning-intro)
2. Configure [external access](https://cloud.google.com/apigee/docs/api-platform/get-started/configure-routing#external-access) for API traffic to your Apigee X instance
3. Access to deploy proxies, create products, apps and developers in Apigee
4. Make sure the following tools are available in your terminal's $PATH (Cloud Shell has these preconfigured)
    * [gcloud SDK](https://cloud.google.com/sdk/docs/install)
    * unzip
    * curl
    * jq
    * npm
# (QuickStart) Setup using CloudShell

Use the following GCP CloudShell tutorial, and follow the instructions.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/apigee-samples&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=basic-quota/docs/cloudshell-tutorial.md)

## Setup instructions

1. Clone the `apigee-samples` repo, and switch the `basic-quota` directory


```bash
git clone https://github.com/GoogleCloudPlatform/apigee-samples.git
cd apigee-samples/basic-quota
```

2. Edit `env.sh` and configure the following variables:

* `PROJECT` the project where your Apigee organization is located
* `APIGEE_HOST` the externally reachable hostname of the Apigee environment group that contains APIGEE_ENV
* `APIGEE_ENV` the Apigee environment where the demo resources should be created

Now source the `env.sh` file

```bash
source ./env.sh
```

3. Deploy Apigee API proxies, products and apps

```bash
./deploy-basic-quota.sh
```

## Testing the Quota Proxy
To run the tests, first retrieve Node.js dependencies with:
```
npm install
```
Ensure the following environment variables have been set correctly:
* `PROXY_URL`
* `CLIENT_ID_1`
* `CLIENT_ID_2`

and then run the tests:
```
npm run test
```

## Example Requests
To manually test the proxy, make requests using the API keys created by the deploy script.

If the deployment has been successfully executed, you will see two products (`basic-quota-trial` & `basic-quota-premium`) and two corresponding apps (`basic-quota-trial-app` & `basic-quota-premium-app`) created for testing purposes. Instructions for how to find
application credentials can be found [here](https://cloud.google.com/apigee/docs/api-platform/publish/creating-apps-surface-your-api#view-api-key).

The requests can be made like this:
```
curl https://$APIGEE_HOST/v1/samples/basic-quota?apikey=$CLIENT_ID_1
```

When testing with the `basic-quota-trial-app` key, the response will show 10 requests _per minute_ allowed. Each subsequent response will increment the counter until the quota is exceeded.

When testing with the `basic-quota-premium-app` key, the response will instead show 1000 requests _per hour_.

## Cleanup

If you want to clean up the artefacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-basic-quota.sh
```