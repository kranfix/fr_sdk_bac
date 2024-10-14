import 'package:fr_sdk_bac/fr_node.dart';

abstract class AuthRepo {
  // TODO: Create a struct with expected data of the journey instead of raw data
  Future<FRNode> login();

  Future<void> logout();
}

extension type AuthLoginError(Exception e) implements Exception {}
extension type AuthLogoutError(Exception e) implements Exception {}
