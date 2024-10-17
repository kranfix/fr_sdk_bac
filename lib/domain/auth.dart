import 'package:fr_sdk_bac/fr_node.dart';

abstract class AuthRepo {
  // TODO: Create a struct with expected data of the journey instead of raw data
  Future<FRNode> login();

  Future<void> logout();

  Future<UserInfo?> getUserInfo();
}

extension type AuthLoginError(Exception e) implements Exception {}
extension type AuthLogoutError(Exception e) implements Exception {}
extension type GetUserInfoError(Exception e) implements Exception {}

class UserInfo {
  const UserInfo({required this.name, required this.email});

  final String name;
  final String email;
}
