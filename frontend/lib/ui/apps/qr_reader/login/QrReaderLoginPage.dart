import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/qr_reader/login/QrReaderLoginContent.dart';
import 'package:frontend/ui/commons/CustomScaffold.dart';

class QrReaderLoginPage extends StatelessWidget {
  const QrReaderLoginPage({super.key});

  static const String routeName = 'qr-reader-login';
  static const String path = 'qr_reader_login';

  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(child: QrReaderLoginContent());
  }
}
