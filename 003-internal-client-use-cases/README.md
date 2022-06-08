# 003 - Internal Client Use Cases
This example shows a series of use-cases that can benefit internal APIs - that is, APIs that are owned and produced by the same company that also controls/develops the API Clients. These APIs can be either privately or publicly exposed.

## What's in it for the customer
This example shows the value of Apigee for internal APIs. 
- **Custom Routing**: this example has 2 potential target servers. The example routing business rule is - if the client provides a *routeto* header, that will select the destination. Otherwise, if not explictly chosen, a property set will be used to define the default target.
- **Data Normalization**: in this example, each backend returns the data in a specific way, but the client expects the API to always return the data in a specific way (content in the body). For each target, Apigee normalizes this data.
- **Caching**: One of the backends is known to be slow (4-5s). Therefore, caching is being used to accelerate the response for the results of this specific slow backend.
- **Target Analytics**: in Apigee Analytics, we can have clear data about the experience and metrics being provided from the perspective of each target destination. This can be used to reinforce SLAs with business partners.

## How to test / demonstrate
This demo uses 2x mocked backends/targets. POST a JSON object like {"cliente":"yourname"} - this will route the request to the default target (as set in the PropertySet file in the proxy).

Next, force the same POST to use a specific backend, first with *routeTo = itau* header. 

Next, force the same POST to use the *routeTo = bradesco* header. Notice it takes longer in the Debug view. Do it again, and the previous response will be cached.

Play with Analytics - Custom Reports with Target Host statistics

### Shown features
 - Data normalization across multiple possible Targets/Backends (EV, AM)
 - Routing Rules / Conditional Execution
 - Caching
 - Property Sets for setting business rules (default backend if not explict, for example)