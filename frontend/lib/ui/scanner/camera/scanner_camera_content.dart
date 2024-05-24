import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/text_widgets.dart';
import 'package:frontend/ui/scanner/camera/camera_widget.dart';

typedef QrCallback = void Function(String? qr, String campaignId, bool checkOnly);
typedef CameraOnOff = void Function(bool on);

class ScannerCameraContent extends StatefulWidget {
  const ScannerCameraContent({
    super.key,
    required this.campaignId,
    this.campaignName,
    required this.checkOnly,
    this.camera,
    this.infoText,
    required this.controller,
    required this.initializeControllerFuture,
    required this.onQrCodeFound,
  });

  final String campaignId;
  final String? campaignName;
  final bool checkOnly;
  final CameraDescription? camera;
  final String? infoText;
  final CameraController controller;
  final Future<void> initializeControllerFuture;
  final QrCallback onQrCodeFound;

  @override
  State<ScannerCameraContent> createState() => _ScannerCameraContentState();
}

class _ScannerCameraContentState extends State<ScannerCameraContent> with WidgetsBindingObserver {
  late bool _checkOnly;

  @override
  void initState() {
    _checkOnly = widget.checkOnly;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
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
                modeSelectionButton(context, lang.check_entitlement, _checkOnly, onTap: () {
                  if (!_checkOnly) {
                    setState(() {
                      _checkOnly = true;
                    });
                  }
                }),
                modeSelectionButton(context, lang.enter_consumption, !_checkOnly, onTap: () {
                  if (_checkOnly) {
                    setState(() {
                      _checkOnly = false;
                    });
                  }
                }),
              ],
            ),
            mediumVerticalSpacer(),
            if (widget.camera != null)
              CameraWidget(
                checkOnly: _checkOnly,
                campaignId: widget.campaignId,
                camera: widget.camera!,
                controller: widget.controller,
                initializeControllerFuture: widget.initializeControllerFuture,
                infoText: widget.infoText,
                onQrCodeFound: widget.onQrCodeFound,
              )
            else
              centeredText(lang.camera_not_available_load_again),
            mediumVerticalSpacer(),
            TextButton(
              child: Text(
                lang.search_person_manually,
                style: textTheme.bodyLarge!.copyWith(
                    color: colorScheme.onPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: colorScheme.onPrimary),
              ),
              onPressed: () {
                navigationService.goNamedWithCampaignId(context, ScannerRoutes.scannerPersonList.name,
                    queryParameters: {'campaignId': widget.campaignId, 'checkOnly': _checkOnly.toString()});
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
