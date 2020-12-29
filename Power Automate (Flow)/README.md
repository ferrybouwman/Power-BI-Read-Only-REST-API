# Power Automate / Flow to consume Power BI Asynchronous Unified Scanning API
This flow provides a basis for your Power BI monitoring needs, based on the newly released Admin APIs.

For more information, check this blog post:
https://powerbi.microsoft.com/en-us/blog/announcing-new-admin-apis-and-service-principal-authentication-to-make-for-better-tenant-metadata-scanning/

In short, what this flow does:

1) Receive a HTTP request (so you can have this flow triggered by a separate scheduled flow, or by directly consuming this flow in Power BI, more on this below).
2) Retrieve list with workspace Ids which have been modified since a given date, or a full report.
3) Split workspaces in batches of 100 and request details. 
4) Retrieve details in separate loop, since the API is asynchronous.
5) Respond to HTTP request with JSON file.

This flow has one dependency
1) Created an application registration (WITHOUT API permissions in Azure AD), put in a security group and have the security group in the Power BI Admin settings enabled for the use of the read-only Admin APIs, see blog post mentioned above.
