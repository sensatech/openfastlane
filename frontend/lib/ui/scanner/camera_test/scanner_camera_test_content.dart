/*
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/scanner/camera/camera_widget.dart';
import 'package:frontend/ui/scanner/camera_test/scanner_camera_test_vm.dart';

class ScannerCameraTestContent extends StatefulWidget {
  const ScannerCameraTestContent({
    super.key,
  });

  @override
  State<ScannerCameraTestContent> createState() {
    return _ScannerCameraTestContentState();
  }
}

class _ScannerCameraTestContentState extends State<ScannerCameraTestContent> {
  String? lastBarcode;
  final bool _readOnly = true;

  @override
  void initState() {
    super.initState();
    lastBarcode = null;
  }

  void updateBarcode(String? barcode) {
    setState(() {
      lastBarcode = barcode;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    ScannerCameraTestVM viewModel = sl<ScannerCameraTestVM>();
    viewModel.prepare();
    return BlocBuilder<ScannerCameraTestVM, ScannerCameraTestState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is CameraInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CamerasLoaded) {
            return SingleChildScrollView(
                child: Column(
              children: [
                CameraWidget(readOnly: _readOnly, onQrCodeFound: (qrCode, campaignId) {}, campaignId: 'campaignId')
              ],
            ));
          } else if (state is CamerasError) {
            return Column(
              children: [
                Center(child: Text(state.error.toString())),
                Expanded(
                    child: CameraWidget(
                        readOnly: _readOnly, onQrCodeFound: (qrCode, campaignId) {}, campaignId: 'campaignId')),
              ],
            );
          } else {
            return Center(child: Text(lang.error_load_again));
          }
        });
  }
}
*/
