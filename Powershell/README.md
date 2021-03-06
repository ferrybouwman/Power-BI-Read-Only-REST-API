# Powershell script to consume Power BI Asynchronous Unified Scanning API
This script provides a basis for your Power BI monitoring needs, based on the newly released Admin APIs.

For more information, check this blog post:
https://powerbi.microsoft.com/en-us/blog/announcing-new-admin-apis-and-service-principal-authentication-to-make-for-better-tenant-metadata-scanning/

In short, what this script does:

1) Retrieve list with workspace Ids which have been modified since a given date, or a full report.
2) Split workspaces in batches of 100 and request details. 
3) Retrieve details in separate loop, since the API is asynchronous.
4) Output to file.

This script has two dependencies
1) Created an application registration (WITHOUT API permissions in Azure AD), put in a security group and have the security group in the Power BI Admin settings enabled for the use of the read-only Admin APIs, see blog post mentioned above.
2) Installed Powershell module 'PowerBIPS': https://www.powershellgallery.com/packages/PowerBIPS
