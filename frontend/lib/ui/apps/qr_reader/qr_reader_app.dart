import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/qr_reader/login/qr_reader_login_page.dart';

class QrReaderApp extends StatelessWidget {
  const QrReaderApp({super.key});

  static const String routeName = 'qr-reader';
  static const String path = '/qr_reader';

  @override
  Widget build(BuildContext context) {
    // here we will check for the login status in a global cubit
    // for now we will just return the login page
    return const QrReaderLoginPage();
  }
}
