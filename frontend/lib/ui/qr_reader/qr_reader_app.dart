import 'package:flutter/material.dart';
import 'package:frontend/ui/qr_reader/login/qr_reader_login_page.dart';

class QrReaderApp extends StatelessWidget {
  const QrReaderApp({super.key});

  static const String routeName = 'scanner';
  static const String path = 'scanner';

  @override
  Widget build(BuildContext context) {
    // here we will check for the login status in a global cubit
    // for now we will just return the login page
    return const QrReaderLoginPage();
  }
}
