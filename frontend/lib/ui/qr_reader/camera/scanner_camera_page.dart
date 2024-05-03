import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/camera/scanner_camera_content.dart';

class ScannerCameraPage extends StatelessWidget {
  final String campaignId;
  final bool readOnly;

  const ScannerCameraPage({super.key, required this.campaignId, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ScannerScaffold(
      title: 'QR-Code scannen',
      content: ScannerCameraContent(campaignId: campaignId),
      backgroundColor: colorScheme.primary,
    );
  }
}
