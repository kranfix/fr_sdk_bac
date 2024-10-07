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
      return const FRSdk();
    } on PlatformException catch (e) {
      debugPrint("SDK Start Failed: '${e.message}'.");
      throw StartError();
    }
  }

  Future<String> callEndpoint(
    String url,
    HttpMethod method,
    String body,
    double amount,
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
      throw CallEndpointError.fromPlatformException(e);
    } catch (e) {
      debugPrint('SDK: $e');
      throw CallEndpointError.unexpected();
    }
  }

  Future<NextAction> next(FRNode currentNode) async {
    final jsonResponse = jsonEncode(currentNode.toJson());

    try {
      //Submitting the node. This will return either a new node or a success/failure message
      String result = await platform.invokeMethod('next', jsonResponse);
      Map<String, dynamic> response = jsonDecode(result);
      if (response["type"] == "LoginSuccess") {
        //_navigateToNextScreen(context);
        //process the results
        debugPrint("Transaction successful");
        return LoginSuccessNext();
      } else {
        Map<String, dynamic> frNodeMap = jsonDecode(result);
        /*Map<String, dynamic> callback = frNodeMap["frCallbacks"][0];
        if ( callback["type"] == "WebAuthnRegistrationCallback") {
          _webAuthentication(callback);
        }
        else {*/
        final frNode = FRNode.fromJson(frNodeMap);
        return NextHandleNode(frNode);
        //}
      }
    } on PlatformException catch (e) {
      debugPrint('SDK Error: $e');
      throw NextError.fromPlatformException(e);
    } catch (e) {
      debugPrint('SDK Error: $e');
      throw NextError.unexpected();
    }
  }
}

class StartError implements Exception {}

enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  const HttpMethod(this.name);

  final String name;
}

class CallEndpointError implements Exception {
  CallEndpointError.fromPlatformException(PlatformException exception)
      : platformException = exception;

  CallEndpointError.unexpected() : platformException = null;

  final PlatformException? platformException;
}

class NextError implements Exception {
  NextError.fromPlatformException(PlatformException exception)
      : platformException = exception;

  NextError.unexpected() : platformException = null;

  final PlatformException? platformException;
}

sealed class NextAction {}

class LoginSuccessNext extends NextAction {}

class NextHandleNode extends NextAction {
  NextHandleNode(this.frNode);

  final FRNode frNode;
}
