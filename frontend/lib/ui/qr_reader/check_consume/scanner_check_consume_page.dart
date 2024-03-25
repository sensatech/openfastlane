import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/check_consume/scanner_check_consume_content.dart';

class ScannerCheckConsumePage extends StatelessWidget {
  final String? campaignId;

  const ScannerCheckConsumePage({super.key, this.campaignId});

  static const String routeName = 'scanner-campaigns';
  static const String path = 'check-consume/:campaignId';

  @override
  Widget build(BuildContext context) {
    return const ScannerScaffold(content: ScannerCheckConsumeContent());
  }
}
