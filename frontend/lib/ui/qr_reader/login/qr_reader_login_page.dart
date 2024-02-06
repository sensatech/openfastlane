import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:frontend/ui/qr_reader/login/qr_reader_login_content.dart';

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
