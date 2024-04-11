import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/qr_reader/camera_test/scanner_camera_test_vm.dart';
import 'package:frontend/ui/qr_reader/camera/camera_widget.dart';

class ScannerCameraTestContent extends StatefulWidget {
  const ScannerCameraTestContent({super.key});

  @override
  State<ScannerCameraTestContent> createState() {
    return _ScannerCameraTestContentState();
  }
}

class _ScannerCameraTestContentState extends State<ScannerCameraTestContent> {
  String? lastBarcode;

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
            return const SingleChildScrollView(
                child: Column(
              children: [CameraWidget()],
            ));
          } else if (state is CamerasError) {
            return Column(
              children: [
                Center(child: Text(state.error.toString())),
                const Expanded(child: CameraWidget()),
              ],
            );
          } else {
            return Center(child: Text(lang.error_load_again));
          }
        });
  }
}
