abstract class AuthRepo {
  Future<LoginData> loginWithUserAndPassword(String username, String password);

  Future<void> logout();

  Future<UserInfo?> getUserInfo();
}

class LoginData {
  LoginData({required this.sessionToken});

  final String sessionToken;
}

extension type AuthLoginError(Exception e) implements Exception {
  AuthLoginError.message(String msg) : e = Exception(msg);
}
extension type AuthLogoutError(Exception e) implements Exception {}
extension type GetUserInfoError(Exception e) implements Exception {}

class UserInfo {
  const UserInfo({required this.name, required this.email});

  final String name;
  final String email;
}
