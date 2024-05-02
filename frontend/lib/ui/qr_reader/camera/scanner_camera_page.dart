import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/camera/scanner_camera_content.dart';
import 'package:frontend/ui/qr_reader/camera/scanner_camera_vm.dart';

class ScannerCameraPage extends StatefulWidget {
  final String campaignId;
  final bool readOnly;

  const ScannerCameraPage({super.key, required this.campaignId, required this.readOnly});

  @override
  State<ScannerCameraPage> createState() => _ScannerCameraPageState();
}

class _ScannerCameraPageState extends State<ScannerCameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  void initCam(CameraDescription camera) {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;

    NavigationService navigationService = sl<NavigationService>();
    ScannerCameraViewModel viewModel = sl<ScannerCameraViewModel>();
    viewModel.prepare(widget.campaignId);

    String? infoText;
    String? campaignName;
    CameraDescription? camera;
    return ScannerScaffold(
      content: BlocConsumer<ScannerCameraViewModel, ScannerCameraState>(
        bloc: viewModel,
        listener: (context, state) {
          if (state is EntitlementFound) {
            navigationService.goNamedWithCampaignId(context, ScannerRoutes.scannerEntitlement.name,
                pathParameters: {'entitlementId': state.entitlementId},
                queryParameters: {'checkOnly': state.checkOnly.toString()});
          }
          if (state is ScannerCameraError) {
            if (state.errorType == ScannerCameraErrorType.noQrCodeFound) {
              infoText = 'Kein QR-Code gefunden';
            } else if (state.errorType == ScannerCameraErrorType.wrongFormat) {
              infoText = 'QR-Code hat falsches Format';
            } else if (state.errorType == ScannerCameraErrorType.entitlementOfWrongCampaign) {
              infoText = 'Anspruchsberechtigung gehört nicht zur ausgewählten Kampagne';
            } else if (state.errorType == ScannerCameraErrorType.noEntitlementFound) {
              infoText = 'Keine Anspruchsberechtigung gefunden';
            }
          }
        },
        builder: (context, state) {
          if (state is ScannerCameraInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerCameraUiLoaded) {
            campaignName = state.campaign.name;
            camera = state.camera;
            if (camera != null) {
              initCam(camera!);
            }
          } else if (state is ScannerCameraError && state.errorType == ScannerCameraErrorType.unknownError) {
            return Center(child: Text(lang.error_load_again));
          } else if (state is ScannerCameraLoading) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(mediumPadding),
                    child: CircularProgressIndicator(color: colorScheme.onPrimary),
                  ),
                  Text(
                    '... Kamera wird geladen',
                    style: textTheme.headlineSmall!.copyWith(color: colorScheme.onPrimary),
                  )
                ],
              ),
            );
          }
          return ScannerCameraContent(
              campaignId: widget.campaignId,
              campaignName: campaignName,
              readOnly: widget.readOnly,
              camera: camera,
              infoText: infoText,
              controller: _controller,
              initializeControllerFuture: _initializeControllerFuture,
              onQrCodeFound: (qrCode, campaignId, checkOnly) {
                viewModel.checkQrCode(qrCode: qrCode, campaignId: campaignId, checkOnly: checkOnly);
              });
        },
      ),
      backgroundColor: colorScheme.primary,
    );
  }
}
