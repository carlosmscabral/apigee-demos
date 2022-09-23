# 004 - External Token Verify 

This shows a simple example where the "ownership" of client credentials and token issuance is external to Apigee. In this setup we are not storing locally the externally-generated token, but just proxying the call to the external Auth Server and verifying the JWT token that was sent. The JWKS is cached locally in Apigee (for 15 seconds, for ease of demonstration, but in the real world it should be much more). It is also shown how Apigee can be used to verify claims (simulating Issuer verification against an expected issuer in a PropertySet), beyond simply signature/JWKS verification.

## What's in it for the customer

## How to install the setup


## How to demo


### Shown features
 - JWKS caching (standard pattern of cache miss, service callout, populate cache)