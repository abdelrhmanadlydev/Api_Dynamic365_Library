import 'dart:convert';
import 'package:http/http.dart' as http;

class D365AuthService {
  final String tenantId;
  final String clientId;
  final String clientSecret;
  final String resource;

  String? _token;
  DateTime? _expiry;

  D365AuthService({
    required this.tenantId,
    required this.clientId,
    required this.clientSecret,
    required this.resource,
  });

  Future<String> getToken() async {
    if (_token != null && _expiry!.isAfter(DateTime.now())) {
      return _token!;
    }

    final response = await http.post(
      Uri.parse('https://login.microsoftonline.com/$tenantId/oauth2/token'),
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
        'resource': resource,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get token: ${response.body}');
    }

    final data = jsonDecode(response.body);
    _token = data['access_token'];
    _expiry = DateTime.now().add(Duration(seconds: data['expires_in'] - 60));
    return _token!;
  }
}
