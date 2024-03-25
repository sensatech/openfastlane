import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/choose_campaign/scanner_choose_campaign_content.dart';

class ScannerCampaignPage extends StatelessWidget {
  const ScannerCampaignPage({super.key});

  // static const String routeName = 'scanner-campaigns';
  // static const String path = 'campaigns';

  @override
  Widget build(BuildContext context) {
    return const ScannerScaffold(content: ScannerCampaignContent());
  }
}
