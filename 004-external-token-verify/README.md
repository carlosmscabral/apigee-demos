# 004 - External Token Verify 

This shows a simple example where the "ownership" of client credentials and token issuance is external to Apigee. In this setup we are not storing locally the externally-generated token, but just proxying the call to the external Auth Server and verifying the JWT token that was sent. The JWKS is cached locally in Apigee (for 15 seconds, for ease of demonstration, but in the real world it should be much more). It is also shown how Apigee can be used to verify claims (simulating Issuer verification against an expected issuer in a PropertySet), beyond simply signature/JWKS verification.

## What's in it for the customer
Apigee can provide much more value when it is the system of record for Apigee Credentials. Productization, rich analytics, granular quota / SLA / rate-limiting, security validations and much more can be achieved. But, even in a scenario where, for any reason, Apigee is not the "owner" of application credentials, we can still provide a lot of value:
- Routing / façading across multiple IdPs/Auth systems
- Protecting (at least at a high level) the token endpoints of these systems
- Validating any signed JWT against any claims and therefore standardizing how this is done for all services and removing this responsibility from backends themselves.
- Standardize error manipulation

## How to install the setup
Just import the proxy with *apigeecli* or any other method you prefer.

## How to demo
- Show how we can protect the external token endpoint with Apigee policies such as RateLimiting, even if this mostly a transparent flow
- Show how we can decode and get all sorts of information from the signed token and populate variables even before actually validating the token
- Show how we can locally cache the JWKS from the remote authorization server to speed up token validation (the PC has a low expiry time of 15 seconds so we can demo that)
- Use an invalid/expired token to show Apigee blocking it
- Change the PropertySet (which we use to basically validate the issuer claim) to something else to show that Apigee will thrown an error and will not forward the request to the backend

### Shown features
 - JWKS caching (standard pattern of cache miss, service callout, populate cache)
 - Validation of external token (generate by Okta in my example)
 - Decoding of external token