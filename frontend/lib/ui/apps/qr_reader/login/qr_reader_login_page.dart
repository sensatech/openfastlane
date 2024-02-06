import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/qr_reader/login/qr_reader_login_content.dart';
import 'package:frontend/ui/commons/ofl_scaffold.dart';

class QrReaderLoginPage extends StatelessWidget {
  const QrReaderLoginPage({super.key});

  static const String routeName = 'qr-reader-login';
  static const String path = 'qr_reader_login';

  @override
  Widget build(BuildContext context) {
    //TODO: needs own scaffold
    return const OflScaffold(content: QrReaderLoginContent());
  }
}
