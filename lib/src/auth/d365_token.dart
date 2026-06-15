class D365Token {
  final String accessToken;
  final DateTime expiresAt;

  const D365Token({
    required this.accessToken,
    required this.expiresAt,
  });

  bool get isExpired {
    return DateTime.now().isAfter(
      expiresAt.subtract(const Duration(minutes: 2)),
    );
  }
}
