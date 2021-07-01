# Power Automate / Flow to consume Power BI Asynchronous Unified Scanning API
This flow provides a basis for your Power BI monitoring needs, based on the newly released Admin APIs.

For more information, check this blog post:
https://powerbi.microsoft.com/en-us/blog/announcing-new-admin-apis-and-service-principal-authentication-to-make-for-better-tenant-metadata-scanning/

In short, what this flow does:

1) Receive a HTTP request (so you can have this flow triggered by a separate scheduled flow, or by directly consuming this flow in Power BI, see example). Currently, there seems to be a limit in Power Automate which cuts off requests that take longer then 2 minutes to progress. When you need a regular, scheduled, full retrieval of all your tenant's data, make the flow scheduled instead of HTTP triggered, in particular for large environments.
2) Retrieve list with workspace Ids which have been modified since a given date, or a full report.
3) Split workspaces in batches of 100 and request details. 
4) Retrieve details in separate loop, since the API is asynchronous.
5) Respond to HTTP request with JSON file.

This flow has one dependency
1) Created an application registration (WITHOUT API permissions in Azure AD), put in a security group and have the security group in the Power BI Admin settings enabled for the use of the read-only Admin APIs, see blog post mentioned above.

How to use?
1) Download zip file from this repository.
2) Import into Power Automate.
3) Set 3 variables: tenant, clientId, clientSecret.
4) Copy HTTP GET URL from trigger (first step) and paste somewhere.
5) Turn on flow.
6) Call this flow from another (scheduled) flow or a script, or DIRECTLY from Power BI. Examples included in repository.
7) Optional since July 1st: Add "&datasetSchema=true&datasetExpressions=true" to the query to obtain DAX and M expressions.
