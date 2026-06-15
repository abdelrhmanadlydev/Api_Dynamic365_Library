import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/d365_token_provider.dart';
import '../exceptions/d365_exception.dart';
import '../query/d365_odata_key.dart';
import '../query/d365_odata_query.dart';
import 'd365_response.dart';

class D365ODataClient {
  final String baseUrl;
  final D365TokenProvider tokenProvider;
  final http.Client httpClient;
  final Duration timeout;

  D365ODataClient({
    required this.baseUrl,
    required this.tokenProvider,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 60),
  }) : httpClient = httpClient ?? http.Client();

  Future<D365Response<List<Map<String, dynamic>>>> getEntitySet({
    required String entityName,
    D365ODataQuery? query,
  }) async {
    final Uri uri = _buildEntitySetUri(
      entityName: entityName,
      query: query,
    );

    final http.Response response = await _send(
      method: 'GET',
      uri: uri,
    );

    final Map<String, dynamic> json = _decodeMap(response.body);

    final List<dynamic> value = json['value'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> rows = value
        .whereType<Map>()
        .map((Map row) => Map<String, dynamic>.from(row))
        .toList();

    return D365Response<List<Map<String, dynamic>>>(
      data: rows,
      statusCode: response.statusCode,
      rawBody: response.body,
      nextLink: _parseNextLink(json),
    );
  }

  Future<D365Response<Map<String, dynamic>>> getEntityByKey({
    required String entityName,
    required D365ODataKey key,
    D365ODataQuery? query,
  }) async {
    final Uri uri = _buildEntityByKeyUri(
      entityName: entityName,
      key: key,
      query: query,
    );

    final http.Response response = await _send(
      method: 'GET',
      uri: uri,
    );

    return D365Response<Map<String, dynamic>>(
      data: _decodeMap(response.body),
      statusCode: response.statusCode,
      rawBody: response.body,
    );
  }

  Future<D365Response<Map<String, dynamic>>> createEntity({
    required String entityName,
    required Map<String, dynamic> payload,
  }) async {
    final Uri uri = _buildEntitySetUri(entityName: entityName);

    final http.Response response = await _send(
      method: 'POST',
      uri: uri,
      body: payload,
    );

    return D365Response<Map<String, dynamic>>(
      data: response.body.trim().isEmpty ? {} : _decodeMap(response.body),
      statusCode: response.statusCode,
      rawBody: response.body,
    );
  }

  Future<D365Response<Map<String, dynamic>>> updateEntity({
    required String entityName,
    required D365ODataKey key,
    required Map<String, dynamic> payload,
  }) async {
    final Uri uri = _buildEntityByKeyUri(
      entityName: entityName,
      key: key,
    );

    final http.Response response = await _send(
      method: 'PATCH',
      uri: uri,
      body: payload,
    );

    return D365Response<Map<String, dynamic>>(
      data: response.body.trim().isEmpty ? {} : _decodeMap(response.body),
      statusCode: response.statusCode,
      rawBody: response.body,
    );
  }

  Future<D365Response<bool>> deleteEntity({
    required String entityName,
    required D365ODataKey key,
  }) async {
    final Uri uri = _buildEntityByKeyUri(
      entityName: entityName,
      key: key,
    );

    final http.Response response = await _send(
      method: 'DELETE',
      uri: uri,
    );

    return D365Response<bool>(
      data: true,
      statusCode: response.statusCode,
      rawBody: response.body,
    );
  }

  Future<D365Response<List<Map<String, dynamic>>>> getNextLink({
    required Uri nextLink,
  }) async {
    final http.Response response = await _send(
      method: 'GET',
      uri: nextLink,
    );

    final Map<String, dynamic> json = _decodeMap(response.body);

    final List<dynamic> value = json['value'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> rows = value
        .whereType<Map>()
        .map((Map row) => Map<String, dynamic>.from(row))
        .toList();

    return D365Response<List<Map<String, dynamic>>>(
      data: rows,
      statusCode: response.statusCode,
      rawBody: response.body,
      nextLink: _parseNextLink(json),
    );
  }

  Future<List<Map<String, dynamic>>> getAllPages({
    required String entityName,
    D365ODataQuery? query,
    int maxPages = 50,
  }) async {
    final List<Map<String, dynamic>> allRows = [];

    D365Response<List<Map<String, dynamic>>> response =
        await getEntitySet(entityName: entityName, query: query);

    allRows.addAll(response.data);

    int page = 1;

    while (response.nextLink != null && page < maxPages) {
      response = await getNextLink(nextLink: response.nextLink!);
      allRows.addAll(response.data);
      page++;
    }

    return allRows;
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
  }) async {
    final token = await tokenProvider.getToken();

    final Map<String, String> headers = {
      'Authorization': 'Bearer ${token.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'OData-Version': '4.0',
      'OData-MaxVersion': '4.0',
    };

    late final http.Response response;

    try {
      switch (method) {
        case 'GET':
          response =
              await httpClient.get(uri, headers: headers).timeout(timeout);
          break;

        case 'POST':
          response = await httpClient
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(timeout);
          break;

        case 'PATCH':
          response = await httpClient
              .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(timeout);
          break;

        case 'DELETE':
          response =
              await httpClient.delete(uri, headers: headers).timeout(timeout);
          break;

        default:
          throw D365Exception(
            message: 'Unsupported HTTP method: $method',
            uri: uri,
          );
      }
    } catch (e) {
      throw D365Exception(
        message: 'D365 request failed: $e',
        uri: uri,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw D365Exception(
        message: 'D365 request returned an error.',
        statusCode: response.statusCode,
        responseBody: response.body,
        uri: uri,
      );
    }

    return response;
  }

  Uri _buildEntitySetUri({
    required String entityName,
    D365ODataQuery? query,
  }) {
    final String cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final Uri uri = Uri.parse('$cleanBaseUrl/data/$entityName');

    if (query == null) {
      return uri;
    }

    return uri.replace(
      queryParameters: query.toQueryParameters(),
    );
  }

  Uri _buildEntityByKeyUri({
    required String entityName,
    required D365ODataKey key,
    D365ODataQuery? query,
  }) {
    final String cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final Uri uri = Uri.parse(
      '$cleanBaseUrl/data/$entityName(${key.toODataKey()})',
    );

    if (query == null) {
      return uri;
    }

    return uri.replace(
      queryParameters: query.toQueryParameters(),
    );
  }

  Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    final dynamic decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw D365Exception(
      message: 'Expected JSON object but received another type.',
      responseBody: body,
    );
  }

  Uri? _parseNextLink(Map<String, dynamic> json) {
    final String? nextLink = json['@odata.nextLink']?.toString();

    if (nextLink == null || nextLink.isEmpty) {
      return null;
    }

    return Uri.parse(nextLink);
  }
}
