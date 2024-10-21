import 'package:fr_sdk_bac/domain/domain.dart';
import 'package:fr_sdk_bac/fr_node.dart';
import 'package:fr_sdk_bac/fr_sdk.dart';

class FRAuthRepo implements AuthRepo {
  FRAuthRepo(this.sdk);

  final FRSdk sdk;

  @override
  Future<LoginData> loginWithUserAndPassword(
      String username, String password) async {
    try {
      final frNode = await sdk.login();
      final loginHandleNode = _identifyLoginJourney(frNode);
      if (loginHandleNode == null) {
        throw AuthLoginError.message("Unsupported Journey");
      }
      switch (loginHandleNode) {
        case WebAuthHandleNode():
          throw AuthLoginError.message("Unsupported Journey");
        case UserAndPasswordHandleNode():
          final (:sessionToken) =
              await handleUserAndPasswordJourney(frNode, username, password);
          return LoginData(sessionToken: sessionToken);
      }
    } on AuthLoginError catch (_) {
      rethrow;
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

  // Handling methods
  LoginHandleNode? _identifyLoginJourney(FRNode frNode) {
    bool hasNameCallback = false;
    String? passwordLabel;
    // Go through the node callbacks and present the UI fields as needed. Check for the type of each callback to determine, what UI element is needed.
    for (var frCallback in frNode.callbacks) {
      if (frCallback.type == "NameCallback") {
        hasNameCallback = true;
      }
      if (frCallback.type == "PasswordCallback") {
        passwordLabel = frCallback.output[0].value;
      }
      if (frCallback.type == "WebAuthnAuthenticationCallback") {
        //return const WebAuthHandleNode();
      }
    }
    if (!hasNameCallback || passwordLabel == null) {
      return null;
    }
    //return UserAndPasswordHandleNode(passwordLabel);
    return const UserAndPasswordHandleNode();
  }

  Future<({String sessionToken})> handleUserAndPasswordJourney(
      FRNode currentNode, String username, String password) async {
    currentNode.callbacks.asMap().forEach((index, frCallback) {
      if (frCallback.type == "NameCallback") {
        frCallback.input[0].value = username;
      }
      if (frCallback.type == "PasswordCallback") {
        frCallback.input[0].value = password;
      }
    });

    final FRNextAction action;
    try {
      action = await sdk.next(currentNode);
    } on FRNextError catch (e) {
      throw AuthLoginError(e);
    }
    switch (action) {
      case FRLoginSuccessNext(:final sessionToken):
        return (sessionToken: sessionToken);
      case FRNextHandleNode():
        throw AuthLoginError.message("Access not granted");
    }
  }
}

sealed class LoginHandleNode {
  const LoginHandleNode();
}

class WebAuthHandleNode extends LoginHandleNode {
  const WebAuthHandleNode();
}

class UserAndPasswordHandleNode extends LoginHandleNode {
  const UserAndPasswordHandleNode();
  // const UserAndPasswordHandleNode(this.passwordLabel);

  // final String passwordLabel;
}
