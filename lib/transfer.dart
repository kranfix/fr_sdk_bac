import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'FRNode.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  static const platform = MethodChannel('forgerock.com/SampleBridge'); //Method channel as defined in the native Bridge code
  late FRNode currentNode;
  late String srcAccount;
  late String destAccount;
  late double amount;

  Future<void> _startTransaction() async {
    try {
      //Call the default login tree.
      final String result = await platform.invokeMethod('callEndpoint', ["https://bacciambl.encore.forgerock.com/transfers",'POST', '{"srcAcct": $srcAccount, "destAcct": $destAccount, "amount": $amount}', true]);
      Map<String, dynamic> frNodeMap = jsonDecode(result);
      // Process the results of the Transfer
    } on PlatformException catch (e) {
      debugPrint('SDK Error: $e');
    }
  }

  void _setSourceAccount(String value) {
    setState(() {
      this.srcAccount = value;
    });
  }

  void _setDestAccount(String value) {
    setState(() {
      this.destAccount = value;
    });
  }

  void _setAmount(String value) {
    setState(() {
      this.amount = double.parse(value);
    });
  }

  // Build the transfer form to initiate transactional authorization
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final ButtonStyle _style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Title(color: Colors.red, child: const Text("BAC PoC Demo - Transfers")),
          centerTitle: true,
          shadowColor: Colors.black,
          elevation: 3,
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red
          ),
        ),
        backgroundColor: Colors.red,
        body: Container(
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Source Account',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Source Account';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                          _setSourceAccount(value!);
                    },
                  ),
                  TextFormField(
                      decoration: const InputDecoration(
                      hintText: 'Enter Destination Account',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                           return 'Please enter the Destination Account';
                        }
                        return null;
                      },
                  ),
                  TextFormField(
                      decoration: const InputDecoration(
                      hintText: 'Enter Transfer Amount in Dollars.',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                        }
                        return null;
                      },
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        style: _style,
                        onPressed: () {
                          _startTransaction();
                        },
                        child: null,
                      ),
                  ),
                ]
            )
          )
        ),
      ),
    );
  }
}
