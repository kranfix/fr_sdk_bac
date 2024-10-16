import 'package:fr_sdk_bac/domain/domain.dart';
import 'package:fr_sdk_bac/fr_node.dart';
import 'package:fr_sdk_bac/fr_sdk.dart';

class FRAuthRepo implements AuthRepo {
  FRAuthRepo(this.sdk);

  final FRSdk sdk;

  @override
  Future<FRNode> login() async {
    try {
      return await sdk.login();
    } on Exception catch (e) {
      throw AuthLoginError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await sdk.logout();
    } on Exception catch (e) {
      throw AuthLoginError(e);
    }
  }

  @override
  Future<UserInfo?> getUserInfo() async {
    try {
      final info = await sdk.getUserInfo();
      if (info == null) return null;
      return UserInfo(
        name: info.name,
        email: info.email,
      );
    } on Exception catch (e) {
      throw GetUserInfoError(e);
    }
  }
}
