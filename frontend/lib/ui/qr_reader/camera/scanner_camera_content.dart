import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/text_widgets.dart';
import 'package:frontend/ui/qr_reader/camera/camera_widget.dart';

typedef QrCallback = void Function(String? qr, String campaignId, bool checkOnly);

class ScannerCameraContent extends StatefulWidget {
  const ScannerCameraContent(
      {super.key,
      required this.campaignId,
      this.campaignName,
      required this.readOnly,
      this.camera,
      this.infoText,
      required this.controller,
      required this.initializeControllerFuture,
      required this.onQrCodeFound,
      h});

  final String campaignId;
  final String? campaignName;
  final bool readOnly;
  final CameraDescription? camera;
  final String? infoText;
  final CameraController controller;
  final Future<void> initializeControllerFuture;
  final QrCallback onQrCodeFound;

  @override
  State<ScannerCameraContent> createState() => _ScannerCameraContentState();
}

class _ScannerCameraContentState extends State<ScannerCameraContent> with WidgetsBindingObserver {
  late bool _readOnly;

  @override
  void initState() {
    _readOnly = widget.readOnly;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // AppLocalizations lang = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    NavigationService navigationService = sl<NavigationService>();

    return Padding(
      padding: EdgeInsets.fromLTRB(mediumPadding, 0, mediumPadding, mediumPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.campaignName ?? '',
                style: textTheme.headlineSmall!.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            mediumVerticalSpacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                modeSelectionButton(context, 'Anspruch prüfen', _readOnly, onTap: () {
                  if (!_readOnly) {
                    setState(() {
                      _readOnly = true;
                    });
                  }
                }),
                modeSelectionButton(context, 'Bezug vornehmen', !_readOnly, onTap: () {
                  if (_readOnly) {
                    setState(() {
                      _readOnly = false;
                    });
                  }
                }),
              ],
            ),
            mediumVerticalSpacer(),
            if (widget.camera != null)
              CameraWidget(
                checkOnly: _readOnly,
                campaignId: widget.campaignId,
                camera: widget.camera!,
                controller: widget.controller,
                initializeControllerFuture: widget.initializeControllerFuture,
                infoText: widget.infoText,
                onQrCodeFound: widget.onQrCodeFound,
              )
            else
              centeredText('Kamera nicht verfügbar. Laden Sie die Seite neu'),
            mediumVerticalSpacer(),
            TextButton(
              child: Text(
                'Person manuell suchen',
                style: textTheme.bodyLarge!.copyWith(
                    color: colorScheme.onPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: colorScheme.onPrimary),
              ),
              onPressed: () {
                widget.controller.dispose();
                navigationService
                    .pushNamedWithCampaignId(context, ScannerRoutes.scannerPersonList.name, queryParameters: {
                  'campaignId': widget.campaignId,
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Expanded modeSelectionButton(BuildContext context, String text, bool isSelected, {Function? onTap}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    Color backgroundColor = isSelected ? colorScheme.secondary : colorScheme.primaryContainer;
    Color textColor = isSelected ? colorScheme.onSecondary : colorScheme.onPrimaryContainer;
    Color? borderColor = !isSelected ? colorScheme.secondary : Colors.transparent;
    return Expanded(
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(color: backgroundColor, border: Border.all(color: borderColor, width: 2.0)),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(mediumPadding),
              child: Text(text,
                  style: textTheme.bodyLarge!.copyWith(color: textColor), overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ),
        ),
        onTap: () {
          if (onTap != null) {
            onTap.call();
          }
        },
      ),
    );
  }
}
