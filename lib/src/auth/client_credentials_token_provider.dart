import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/d365_exception.dart';
import 'd365_token.dart';
import 'd365_token_provider.dart';

class ClientCredentialsTokenProvider implements D365TokenProvider {
  final String tenantId;
  final String clientId;
  final String clientSecret;
  final String resource;
  final http.Client httpClient;

  D365Token? _cachedToken;

  ClientCredentialsTokenProvider({
    required this.tenantId,
    required this.clientId,
    required this.clientSecret,
    required this.resource,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  @override
  Future<D365Token> getToken() async {
    if (_cachedToken != null && !_cachedToken!.isExpired) {
      return _cachedToken!;
    }

    final Uri uri = Uri.parse(
      'https://login.microsoftonline.com/$tenantId/oauth2/token',
    );

    final http.Response response = await httpClient.post(
      uri,
      headers: const {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
        'resource': resource,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw D365Exception(
        message: 'Failed to get D365 access token.',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;

    final String accessToken = json['access_token']?.toString() ?? '';
    final int expiresIn =
        int.tryParse(json['expires_in']?.toString() ?? '') ?? 3600;

    if (accessToken.isEmpty) {
      throw D365Exception(
        message: 'Access token was empty.',
        responseBody: response.body,
      );
    }

    _cachedToken = D365Token(
      accessToken: accessToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );

    return _cachedToken!;
  }
}
