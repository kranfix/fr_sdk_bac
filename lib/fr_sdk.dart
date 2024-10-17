import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fr_sdk_bac/fr_node.dart';

class FRSdk {
  const FRSdk();

  //Method channel as defined in the native Bridge code
  static const platform = MethodChannel('forgerock.com/SampleBridge');

  static Future<FRSdk> start() async {
    try {
      //Start the SDK. Call the frAuthStart channel method to initialise the native SDKs
      await platform.invokeMethod('frAuthStart');
      return const FRSdk();
    } on PlatformException catch (e) {
      debugPrint("SDK Start Failed: '${e.message}'.");
      throw FRStartError();
    }
  }

  Future<FRNode> login() async {
    try {
      //Call the default login tree.
      final String result = await platform.invokeMethod('login');
      Map<String, dynamic> frNodeMap = jsonDecode(result);
      final frNode = FRNode.fromJson(frNodeMap);
      return frNode;
    } on PlatformException catch (e) {
      debugPrint('SDK Login Error: $e');
      throw LoginError.fromPlatformException(e);
    } catch (e) {
      debugPrint('SDK Login Error: Unexpected: $e');
      throw LoginError.unexpected();
    }
  }

  Future<void> logout() async {
    try {
      await platform.invokeMethod('logout');
    } on PlatformException catch (e) {
      throw FRLogoutError.fromPlatformException(e);
    } catch (e) {
      throw FRLogoutError.unexpected();
    }
  }

  Future<FRNode> register() async {
    try {
      // Call the default register tree/journey
      final String result = await platform.invokeMethod('register');
      Map<String, dynamic> frNodeMap = jsonDecode(result);
      return FRNode.fromJson(frNodeMap);
    } on PlatformException catch (e) {
      debugPrint('SDK: $e');
      throw FRRegisterError.fromPlatformException(e);
    } catch (e) {
      throw FRRegisterError.unexpected();
    }
  }

  Future<({String name, String email})?> getUserInfo() async {
    try {
      final String result = await platform.invokeMethod('getUserInfo');
      Map<String, dynamic> userInfoMap = jsonDecode(result);
      return (
        name: userInfoMap["name"] as String,
        email: userInfoMap["email"] as String,
      );
    } on PlatformException catch (e) {
      debugPrint('SDK.getUserInfo: $e');
      return null;
    }
  }

  Future<String> callEndpoint(
    String url,
    HttpMethod method,
    String body,
    bool requireAuthz,
  ) async {
    try {
      //Call the default login tree.
      final String result = await platform.invokeMethod('callEndpoint', [
        url,
        method.name,
        body,
        requireAuthz,
      ]);
      debugPrint("Final response $result");
      /*Map<String, dynamic> frNodeMap = jsonDecode(result);
      var frNode = FRNode.fromJson(frNodeMap);
      currentNode = frNode;
      _handleNode(frNode);*/
      return result;
    } on PlatformException catch (e) {
      debugPrint('SDK: $e');
      throw FRCallEndpointError.fromPlatformException(e);
    } catch (e) {
      debugPrint('SDK: $e');
      throw FRCallEndpointError.unexpected();
    }
  }

  Future<FRNextAction> next(FRNode currentNode) async {
    final jsonResponse = jsonEncode(currentNode.toJson());

    try {
      //Submitting the node. This will return either a new node or a success/failure message
      String result = await platform.invokeMethod('next', jsonResponse);
      Map<String, dynamic> response = jsonDecode(result);
      if (response["type"] == "LoginSuccess") {
        //_navigateToNextScreen(context);
        //process the results
        debugPrint("Transaction successful");
        return FRLoginSuccessNext();
      } else {
        Map<String, dynamic> frNodeMap = jsonDecode(result);
        /*Map<String, dynamic> callback = frNodeMap["frCallbacks"][0];
        if ( callback["type"] == "WebAuthnRegistrationCallback") {
          _webAuthentication(callback);
        }
        else {*/
        final frNode = FRNode.fromJson(frNodeMap);
        return FRNextHandleNode(frNode);
        //}
      }
    } on PlatformException catch (e) {
      debugPrint('SDK Error: $e');
      throw FRNextError.fromPlatformException(e);
    } catch (e) {
      debugPrint('SDK Error: $e');
      throw FRNextError.unexpected();
    }
  }
}

// ------------------ Start ------------------
class FRStartError implements Exception {}

// ------------------ Login ------------------
class LoginError implements Exception {
  LoginError.fromPlatformException(PlatformException exception)
      : platformException = exception;

  LoginError.unexpected() : platformException = null;

  final PlatformException? platformException;
}

// ------------------ Logout ------------------
class FRLogoutError implements Exception {
  FRLogoutError.fromPlatformException(PlatformException exception)
      : platformException = exception;

  FRLogoutError.unexpected() : platformException = null;

  final PlatformException? platformException;
}

// ------------------ Register ------------------
class FRRegisterError implements Exception {
  FRRegisterError.fromPlatformException(PlatformException exception)
      : platformException = exception;

  FRRegisterError.unexpected() : platformException = null;

  final PlatformException? platformException;
}

// ------------------ Call Endpoint ------------------
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  const HttpMethod(this.name);

  final String name;
}

class FRCallEndpointError implements Exception {
  FRCallEndpointError.fromPlatformException(PlatformException exception)
      : platformException = exception;

  FRCallEndpointError.unexpected() : platformException = null;

  final PlatformException? platformException;
}

// ------------------ Next ------------------

class FRNextError implements Exception {
  FRNextError.fromPlatformException(PlatformException exception)
      : platformException = exception;

  FRNextError.unexpected() : platformException = null;

  final PlatformException? platformException;
}

sealed class FRNextAction {}

class FRLoginSuccessNext extends FRNextAction {}

class FRNextHandleNode extends FRNextAction {
  FRNextHandleNode(this.frNode);

  final FRNode frNode;
}
