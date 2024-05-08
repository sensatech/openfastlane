import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/choose_campaign/scanner_choose_campaign_content.dart';

class ScannerCampaignPage extends StatelessWidget {
  const ScannerCampaignPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ScannerScaffold(
      content: const ScannerCampaignContent(),
      backgroundColor: colorScheme.primary,
    );
  }
}
