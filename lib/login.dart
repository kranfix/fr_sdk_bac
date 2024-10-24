import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fr_sdk_bac/fr_sdk.dart';
import 'package:fr_sdk_bac/providers.dart';
import 'package:fr_sdk_bac/transfer.dart';

import 'fr_node.dart';
import 'register.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _fields = <TextField>[];
  final _controllers = <TextEditingController>[];
  //late FRNode currentNode;

  Future<void> _login(String username, String password) async {
    final authRepo = ref.read(authRepoProvider);
    try {
      //Call the default login tree.
      final data = await authRepo.loginWithUserAndPassword(username, password);
    } on LoginError catch (e) {
      debugPrint('SDK Error: $e');
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _next() async {
    // Capture the User Inputs from the UI, populate the currentNode callbacks and submit back to AM

    // currentNode.callbacks.asMap().forEach((index, frCallback) {
    //   if (frCallback.type == "WebAuthnAuthenticationCallback" ||
    //       frCallback.type == "HiddenValueCallback") {
    //     // Do nothing - no input required.
    //   } else {
    //     _controllers.asMap().forEach((controllerIndex, controller) {
    //       if (controllerIndex == index) {
    //         frCallback.input[0].value = controller.text;
    //       }
    //     });
    //   }
    // });

    // try {
    //   final sdk = ref.read(frSdkProvider);
    //   final action = await sdk.next(currentNode);
    //   switch (action) {
    //     case FRLoginSuccessNext():
    //       if (mounted) _navigateToNextScreen(context);
    //     case FRNextHandleNode(:final frNode):
    //       currentNode = frNode;
    //       _handleNode(frNode);
    //   }
    // } on FRNextError catch (e) {
    //   debugPrint('Next Error: $e');
    //   if (mounted) Navigator.pop(context);
    // }
  }

  // Handling methods
  void _handleNode(FRNode frNode) {
    bool webAuthn = false;
    // Go through the node callbacks and present the UI fields as needed. Check for the type of each callback to determine, what UI element is needed.
    for (var frCallback in frNode.callbacks) {
      if (frCallback.type == "NameCallback" ||
          frCallback.type == "PasswordCallback") {
        final controller = TextEditingController();
        final field = TextField(
          controller: controller,
          obscureText: frCallback.type ==
              "PasswordCallback", // If the callback type is 'PasswordCallback', make this a 'secure' textField.
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: frCallback.output[0].value,
          ),
        );
        setState(() {
          _controllers.add(controller);
          _fields.add(field);
        });
      }
      if (frCallback.type == "WebAuthnAuthenticationCallback") {
        webAuthn = true;
        break;
      }
    }
    if (webAuthn) {
      _next();
    }
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransferPage()),
    );
  }

  void _navigateToRegisterScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> showAlertDialog(BuildContext context) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: const Text("Loading"),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _listView(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _fields.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(15.0),
          child: _fields[index],
        );
      },
    );
  }

  Widget _registerButton(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(15.0),
      height: 60,
      child: TextButton(
        onPressed: () async {
          _navigateToRegisterScreen(context);
        },
        child: const Text(
          "Not registered? Create an account now.",
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _okButton(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(15.0),
      height: 60,
      child: TextButton(
        style:
            ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
        onPressed: () async {
          showAlertDialog(context);
          _next();
        },
        child: const Text(
          "Sign in",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Sign-In",
            style: TextStyle(color: Colors.grey[800]),
          ),
          backgroundColor: Colors.grey[200],
        ),
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
            child: Column(
          children: [
            _listView(context),
            _okButton(context),
            _registerButton(context)
          ],
        )));
  }
}
