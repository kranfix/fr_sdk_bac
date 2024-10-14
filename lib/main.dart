import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:fr_sdk_bac/fr_impls/fr_impls.dart";
import "package:fr_sdk_bac/fr_sdk.dart";
import "package:fr_sdk_bac/login.dart";
import "package:fr_sdk_bac/providers.dart";
import "package:fr_sdk_bac/register.dart";
import "package:fr_sdk_bac/home.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final frSdk = await FRSdk.start();
  runApp(
    ProviderScope(
      overrides: [
        frSdkProvider.overrideWithValue(frSdk),
        authRepoProvider
            .overrideWith((ref) => FRAuthRepo(ref.read(frSdkProvider))),
        transferRepoProvider
            .overrideWith((ref) => FRTranferRepo(ref.read(frSdkProvider))),
      ],
      child: const BACMobileApp(),
    ),
  );
}

class BACMobileApp extends StatefulWidget {
  const BACMobileApp({super.key});

  @override
  State<BACMobileApp> createState() => _BACMobileAppState();
}

class _BACMobileAppState extends State<BACMobileApp> {
  int _selectedIndex = 0;

  final _pageOptions = [
    const MyHomePage(),
    const LoginPage(),
    const RegisterPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text(
                'BAC Credomatic - PoC Mobile App',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
            body: _pageOptions[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.login),
                  label: 'Sign In',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.app_registration),
                  label: 'Sign Up',
                )
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blueAccent[800],
              onTap: _onItemTapped,
              backgroundColor: Colors.red,
            )));
  }
}
