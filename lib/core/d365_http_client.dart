import 'dart:convert';

import 'package:http/http.dart' as http;

import 'd365_auth_service.dart';
import 'd365_exceptions.dart';

class D365HttpClient {
  final D365AuthService auth;

  D365HttpClient(this.auth);

  Future<T> get<T>(
    String url,
    T Function(dynamic json) parser,
  ) async {
    return _send<T>('GET', url, parser);
  }

  Future<T> post<T>(
    String url,
    Map<String, dynamic> body,
    T Function(dynamic json) parser,
  ) async {
    return _send<T>('POST', url, parser, body: body);
  }

  Future<void> patch(
    String url,
    Map<String, dynamic> body,
  ) async {
    await _send('PATCH', url, (_) => null, body: body);
  }

  Future<T> _send<T>(
    String method,
    String url,
    T Function(dynamic json) parser, {
    Map<String, dynamic>? body,
  }) async {
    final token = await auth.getToken();

    final response = await http.Request(method, Uri.parse(url))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      })
      ..body = body == null ? '' : jsonEncode(body);

    final streamed = await response.send();
    final text = await streamed.stream.bytesToString();

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      return text.isEmpty ? parser(null) : parser(jsonDecode(text));
    }

    throw D365Exception(text, statusCode: streamed.statusCode);
  }
}
