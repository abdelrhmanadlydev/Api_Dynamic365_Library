class D365Exception implements Exception {
  final String message;
  final int? statusCode;

  D365Exception(this.message, {this.statusCode});

  @override
  String toString() => 'D365Exception($statusCode): $message';
}
