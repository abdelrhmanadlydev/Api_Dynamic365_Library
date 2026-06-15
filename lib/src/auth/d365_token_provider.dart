import 'd365_token.dart';

abstract class D365TokenProvider {
  Future<D365Token> getToken();
}
