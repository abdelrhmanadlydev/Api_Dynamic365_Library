Dynamic365 API Client for Dart & Flutter (v2.0.0)

[![Pub Version](https://img.shields.io/pub/v/dynamic365_api?style=for-the-badge)](https://pub.dev/packages/dynamic365_api)
[![GitHub Stars](https://img.shields.io/github/stars/abdelrhmanadlydev/Api_Dynamic365_Library?style=social)](https://github.com/abdelrhmanadlydev/Api_Dynamic365_Library)

    A Dart & Flutter package for seamless integration with Microsoft Dynamics 365 Web API.
    v2.0.0 introduces a more structured API, enhanced error handling, and optimized performance.

✅ Features

    Automatic OAuth 2.0 authentication with token caching
    
    Full CRUD operations: Create, Read, Update, Delete
    
    Advanced dropdown & key-value data handling
    
    Field selection (fetch only specific fields)
    
    Improved async performance & thread optimization
    
    Flutter & Dart ready

📦 Installation

    Add to your pubspec.yaml:
    
    dependencies:
    dynamic365_api: ^2.0.0
    
    
    Then run:
    
    flutter pub get

🚀 Quick Start

    1. Import the package
        import 'package:dynamic365_api/dynamic365_api.dart';

    2. Initialize the service
      final d365 = D365ApiService(
      tenantId: 'your_tenant_id',
      clientId: 'your_client_id',
      clientSecret: 'your_client_secret',
      resource: 'https://your_org.crm.dynamics.com',
      );

    3. Core Operations
      Fetch data
      final accounts = await d365.getEntityData(entity: 'accounts');
    
    Create record
    await d365.postEntity('contacts', {
    'firstname': 'John',
    'lastname': 'Doe',
    });
    
    Update record
    await d365.updateEntity(
    'accounts',
    {'name': 'New Name'},
    keyField: 'accountid',
    keyValue: '00000000-0000-0000-0000-000000000000',
    );
    
    Delete record
    await d365.deleteEntity(
    'accounts',
    keyField: 'accountid',
    keyValue: '00000000-0000-0000-0000-000000000000',
    );
    
    Dropdown / Key-Value Data
    final dropdown = await d365.getDropdownData(
    entity: 'accounts',
    keyField: 'accountid',
    displayField: 'name',
    );

⚙️ Advanced Usage

    Field selection
    final minimalData = await d365.getEntityFieldsData(
    entity: 'contacts',
    fields: ['fullname', 'email'],
    );

Error handling

    try {
    await d365.getEntityData(entity: 'invoices');
    } catch (e) {
    print('Error: ${e.toString()}');
    // handle specific error scenarios
    }
        
    Authentication
    
    D365ApiService auto-refreshes OAuth 2.0 tokens:
    
    final token = await d365.getAccessToken();

✨ Key Methods

    Feature	Method	Description
    Authentication	getAccessToken()	Auto-refreshing OAuth 2.0 tokens
    Read Data	getEntityData()	Fetch records with optional filtering
    Create Data	postEntity()	Add new records
    Update Data	updateEntity()	Modify existing records
    Delete Data	deleteEntity()	Remove records
    Dropdown Data	getDropdownData()	Key-value pairs for UI components
    Field Selection	getEntityFieldsData()	Fetch only specific fields

📜 License

    This project is licensed under the MIT License.
    See LICENSE
    for details.