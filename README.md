# Dynamic365 API Client for Dart & Flutter

[![Pub Version](https://img.shields.io/pub/v/api_dynamic365_library?style=for-the-badge)](https://pub.dev/packages/api_dynamic365_library)
[![GitHub Stars](https://img.shields.io/github/stars/abdelrhmanadlydev/Api_Dynamic365_Library?style=social)](https://github.com/abdelrhmanadlydev/Api_Dynamic365_Library)

A Dart and Flutter helper package for integrating with Microsoft Dynamics 365 Finance and Operations
OData APIs.

Version `3.0.0` introduces a cleaner OData client, token provider abstraction, paging support,
composite key support, structured error handling, and better support for D365FO `/data` entities.

> This package is designed mainly for Dynamics 365 Finance and Operations OData endpoints.
> For production Flutter mobile apps, avoid storing `clientSecret` directly inside the app. Use a
> secure backend or Azure Function to issue tokens or proxy D365FO requests.

---

## Features

* Dynamics 365 Finance and Operations OData support through `/data` endpoints.
* OAuth 2.0 client credentials token provider.
* Static token provider for backend-generated access tokens.
* Token caching with expiry handling.
* Get entity sets.
* Get entity by key.
* Create entity records.
* Update entity records.
* Delete entity records.
* Composite OData key support.
* OData query builder support:

    * `$select`
    * `$filter`
    * `$top`
    * `$skip`
    * `$orderby`
    * `$count`
    * `cross-company`
    * `dataAreaId` company filtering
* OData paging support using `@odata.nextLink`.
* `getAllPages` helper method.
* Structured response wrapper with status code, raw body, and next link.
* Structured exception handling using `D365Exception`.
* Flutter and Dart ready.

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  api_dynamic365_library: ^3.0.0
```

Then run:

```bash
flutter pub get
```

or for pure Dart projects:

```bash
dart pub get
```

---

## Import

```dart
import 'package:api_dynamic365_library/api_dynamic365_library.dart';
```

---

## Quick Start

### 1. Create a token provider

For internal tools or server-to-server scenarios:

```dart

final tokenProvider = ClientCredentialsTokenProvider(
  tenantId: 'YOUR_TENANT_ID',
  clientId: 'YOUR_CLIENT_ID',
  clientSecret: 'YOUR_CLIENT_SECRET',
  resource: 'https://your-environment.operations.dynamics.com',
);
```

> Warning:
> Do not use `clientSecret` directly in public Flutter mobile apps.
> For production mobile apps, use a backend API or Azure Function.

---

### 2. Create the D365 OData client

```dart

final client = D365ODataClient(
  baseUrl: 'https://your-environment.operations.dynamics.com',
  tokenProvider: tokenProvider,
);
```

---

## Read Entity Data

Example: Read customers from `CustomersV3`.

```dart

final response = await
client.getEntitySet
(
entityName: 'CustomersV3',
query: D365ODataQuery()
    .company('usmf')
    .select([
'CustomerAccount',
'OrganizationName',
'dataAreaId',
])
    .top(10),
);

for (final row in response.data) {
print(row);
}
```

---

## Read Entity By Key

```dart

final response = await
client.getEntityByKey
(
entityName: 'CustomersV3',
key: const D365ODataKey({
'dataAreaId': 'usmf',
'CustomerAccount': 'US-001',
}),
);

print(response.data);
```

---

## Create Entity Record

```dart

final response = await
client.createEntity
(
entityName: 'CustomersV3',
payload: {
'dataAreaId': 'usmf',
'CustomerAccount': 'US-999',
'OrganizationName': 'Test Customer',
'CustomerGroupId': '10',
'CurrencyCode': 'USD',
},
);

print(response.data);
```

---

## Update Entity Record

```dart
await
client.updateEntity
(
entityName: 'CustomersV3',
key: const D365ODataKey({
'dataAreaId': 'usmf',
'CustomerAccount': 'US-999',
}),
payload: {
'OrganizationName': 'Updated Customer Name',
},
);
```

---

## Delete Entity Record

```dart
await
client.deleteEntity
(
entityName: 'CustomersV3',
key: const D365ODataKey({
'dataAreaId': 'usmf',
'CustomerAccount': 'US-999',
})
,
);
```

---

## OData Query Examples

### Select fields

```dart

final query = D365ODataQuery().select([
  'CustomerAccount',
  'OrganizationName',
]);
```

### Filter records

```dart

final query = D365ODataQuery().filter(
  "CustomerGroupId eq '10'",
);
```

### Filter by company

```dart

final query = D365ODataQuery().company('usmf');
```

This adds:

```text
dataAreaId eq 'usmf'
```

to the OData filter.

### Cross company

```dart

final query = D365ODataQuery().crossCompany();
```

### Top and skip

```dart

final query = D365ODataQuery()
    .top(50)
    .skip(100);
```

### Order by

```dart

final query = D365ODataQuery().orderBy([
  'CustomerAccount asc',
]);
```

### Count

```dart

final query = D365ODataQuery().count();
```

---

## Paging

D365FO OData may return `@odata.nextLink` for large result sets.

### Manual paging

```dart

final firstPage = await
client.getEntitySet
(
entityName: 'CustomersV3',
query: D365ODataQuery().top(100),
);

if (firstPage.nextLink != null) {
final secondPage = await client.getNextLink(
nextLink: firstPage.nextLink!,
);

print(secondPage.data);
}
```

### Get all pages

```dart

final rows = await
client.getAllPages
(
entityName: 'CustomersV3',
query: D365ODataQuery().top(100),
maxPages: 20,
);

print
(
rows
.
length
);
```

---

## Composite OData Keys

Many D365FO entities use composite keys.

```dart

const key = D365ODataKey({
  'dataAreaId': 'usmf',
  'ItemNumber': '1000',
});
```

The generated OData key will be:

```text
dataAreaId='usmf',ItemNumber='1000'
```

---

## Using a Backend Token

For production Flutter apps, the recommended approach is:

```text
Flutter App
    ↓
Backend API / Azure Function
    ↓
Dynamics 365 Finance and Operations
```

Your backend should handle the client credentials flow securely and return a short-lived access
token to the app.

Example using `StaticTokenProvider`:

```dart

final tokenProvider = StaticTokenProvider(
  accessToken: 'ACCESS_TOKEN_FROM_BACKEND',
  expiresAt: DateTime.now().add(
    const Duration(minutes: 50),
  ),
);

final client = D365ODataClient(
  baseUrl: 'https://your-environment.operations.dynamics.com',
  tokenProvider: tokenProvider,
);
```

When your backend returns a new token:

```dart
tokenProvider.updateToken
(
accessToken: 'NEW_ACCESS_TOKEN',
expiresAt: DateTime.now().add(
const Duration(minutes: 50
)
,
)
,
);
```

---

## Error Handling

The package throws `D365Exception` for token errors, HTTP errors, timeout errors, and invalid
responses.

```dart
try {
final response = await client.getEntitySet(
entityName: 'CustomersV3',
query: D365ODataQuery().top(10),
);

print(response.data);
} on D365Exception catch (e) {
print('D365 error: ${e.message}');
print('Status code: ${e.statusCode}');
print('Response body: ${e.responseBody}');
} catch (e) {
print('Unexpected error: $e');
}
```

---

## Main Classes

| Class                            | Description                                                |
|----------------------------------|------------------------------------------------------------|
| `D365ODataClient`                | Main client for D365FO OData operations.                   |
| `D365ODataQuery`                 | Builds OData query parameters.                             |
| `D365ODataKey`                   | Builds single or composite OData keys.                     |
| `D365TokenProvider`              | Base abstraction for token providers.                      |
| `ClientCredentialsTokenProvider` | Gets OAuth token using client credentials.                 |
| `StaticTokenProvider`            | Uses an access token provided by another source.           |
| `D365Response<T>`                | Wraps response data, status code, raw body, and next link. |
| `D365Exception`                  | Structured exception for D365 errors.                      |

---

## Security Notes

Do not store Azure AD `clientSecret` inside a public Flutter mobile or web app.

Recommended production architecture:

```text
Flutter App
    ↓
Your Backend API
    ↓
D365FO OData / Custom Service
```

Use direct `ClientCredentialsTokenProvider` only for:

* Internal apps.
* Admin tools.
* Local testing.
* Backend/server-side Dart apps.

---

## Supported D365FO Endpoint Style

This package expects D365FO OData URLs like:

```text
https://your-environment.operations.dynamics.com/data/CustomersV3
```

It is not intended for Dataverse CRM Web API URLs like:

```text
https://your-org.crm.dynamics.com/api/data/v9.2/accounts
```

---

## License

This project is licensed under the MIT License.

See the `LICENSE` file for details.
