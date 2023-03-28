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