# 002 - Quota Per Error
This example shows a custom quota scenario where we want to block requests to the API if we count five 5XX errors in the last minute (rolling window). All other requests will be allowed freely.

## What's in it for the customer
This example shows how flexible Apigee can be with setting your custom business rules for APIs. We can parametrize *everything*, create custom rules/logic on a per API, client ID, API Product or virtually any dynamically defined parameter during proxy execution. 

## How to test
This demo uses httpbin.org as a target/backend. Therefore, you can simulate 5XX errors by calling the proxy as

```
curl https://APIGEE_HOSTNAME/v1/quota-per-error/status/500
```

You can also force other errors (such as 400) and show in the debug/trace view that those are not counted.

```
curl https://APIGEE_HOSTNAME/v1/quota-per-error/status/400
```

### Shown features
 - Quota Policy (CountOnly, EnforceOnly, SharedName, rollingwindow)
 - Error Flow (TargetEP, Fault Rule, Conditions)