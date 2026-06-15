class D365Exception implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;
  final Uri? uri;

  const D365Exception({
    required this.message,
    this.statusCode,
    this.responseBody,
    this.uri,
  });

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();

    buffer.write('D365Exception: $message');

    if (statusCode != null) {
      buffer.write(' | StatusCode: $statusCode');
    }

    if (uri != null) {
      buffer.write(' | Uri: $uri');
    }

    if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.write(' | Response: $responseBody');
    }

    return buffer.toString();
  }
}
