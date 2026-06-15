import 'd365_token.dart';
import 'd365_token_provider.dart';

class StaticTokenProvider implements D365TokenProvider {
  D365Token _token;

  StaticTokenProvider({
    required String accessToken,
    required DateTime expiresAt,
  }) : _token = D365Token(
          accessToken: accessToken,
          expiresAt: expiresAt,
        );

  void updateToken({
    required String accessToken,
    required DateTime expiresAt,
  }) {
    _token = D365Token(
      accessToken: accessToken,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<D365Token> getToken() async {
    return _token;
  }
}
