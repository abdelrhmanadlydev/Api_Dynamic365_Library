## 3.0.0

* Refactored the library structure to better support Microsoft Dynamics 365 Finance and Operations
  OData APIs.
* Added `D365ODataClient` for working with D365FO data entities through `/data` endpoints.
* Added support for OData query options:

  * `$select`
  * `$filter`
  * `$top`
  * `$skip`
  * `$orderby`
  * `$count`
  * `cross-company`
  * `dataAreaId` company filtering
* Added support for CRUD operations:

  * Get entity sets
  * Get entity by key
  * Create entity
  * Update entity
  * Delete entity
* Added support for composite OData keys using `D365ODataKey`.
* Added paging support through `@odata.nextLink`.
* Added `getAllPages` helper method to retrieve multiple OData pages.
* Added token provider abstraction using `D365TokenProvider`.
* Added `ClientCredentialsTokenProvider` for server-to-server and internal testing scenarios.
* Added `StaticTokenProvider` for backend-generated access tokens.
* Added structured error handling using `D365Exception`.
* Added `D365Response` wrapper to return response data, status code, raw response body, and next
  link.
* Improved package exports from the main library file.
* Updated documentation and usage examples for D365FO OData scenarios.
* Marked direct client secret usage in Flutter mobile apps as not recommended for production.

## 2.0.0

* Initial release of dynamic365_api library.
* Provides basic functionality for integrating with Microsoft Dynamics 365 APIs.
