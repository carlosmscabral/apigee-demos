# 004 - External Token Verify 

This shows a simple example where the "ownership" of client credentials and token issuance is external to Apigee. In this setup we are not storing locally the externally-generated token, but just proxying the call to the external Auth Server and verifying the JWT token that was sent. The JWKS is cached locally in Apigee (for 15 seconds, for ease of demonstration, but in the real world it should be much more). It is also shown how Apigee can be used to verify claims (simulating Issuer verification against an expected issuer in a PropertySet), beyond simply signature/JWKS verification.

## What's in it for the customer
This example bundles together a lot of concepts to show, at a high-level, the full depth of API Management capabilities of Apigee. Flexibility, ease of use, the possibility of bringing business aspects into API design can be shown.

## How to install the setup
This repo contains
 - An import script for import the demo assets into your Apigee X/Hybrid Org - *import_config.sh*
 - A Risks proxy in the *apiproxy* folder
 - Dev/App/Product config files used by the import script to create these resources in Apigee.
 - Postman collection/environment to create test calls towards the environment.

This setup assumes you have full access to a working Apigee X/Hybrid setup (it can be an eval Apigee org, no problem!). Also, this assumes you have the CLI apigeecli installed in your machine - https://github.com/apigee/apigeecli 

Make the *import_config.sh* file executable (chmod +x) and execute it like
````
'import_config.sh {org} {env}'
````
with your Apigee Org as the first arg and Env as the second one.

The script will import/create all needed resources for the demo.

In Postman, import the collection and update the public_dev_host variable with the Public endpoint hostname for your Apigee instance. The collection has two calls, one simulating the Premium Client (FariaLimer) and the other one simulating the Standard Client (ManueldaPadaria)


## How to demo
Explain the overall scenario around API Products, the different backends (legacy and new), an execute the different calls to show the different behavior for each.

### Shown features
 - JWKS caching (standard pattern of cache miss, service callout, populate cache)