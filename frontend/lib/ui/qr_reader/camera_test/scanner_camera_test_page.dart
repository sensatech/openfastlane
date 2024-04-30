import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/camera_test/scanner_camera_test_content.dart';

class ScannerCameraTestPage extends StatelessWidget {
  const ScannerCameraTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScannerScaffold(title: 'Scannen Test', content: ScannerCameraTestContent());
  }
}
