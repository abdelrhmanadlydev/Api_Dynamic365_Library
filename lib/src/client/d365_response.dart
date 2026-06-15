class D365Response<T> {
  final T data;
  final int statusCode;
  final Uri? nextLink;
  final String rawBody;

  const D365Response({
    required this.data,
    required this.statusCode,
    required this.rawBody,
    this.nextLink,
  });
}
