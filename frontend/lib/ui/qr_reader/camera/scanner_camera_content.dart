import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/qr_reader/camera/camera_widget.dart';
import 'package:frontend/ui/qr_reader/camera/scanner_camera_vm.dart';

class ScannerCameraContent extends StatefulWidget {
  const ScannerCameraContent({super.key, required this.campaignId, required this.readOnly});

  final String campaignId;
  final bool readOnly;

  @override
  State<ScannerCameraContent> createState() => _ScannerCameraContentState();
}

class _ScannerCameraContentState extends State<ScannerCameraContent> {
  //TODO: implement query parameter
  bool _readOnly = true;

  @override
  void initState() {
    _readOnly = widget.readOnly;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    NavigationService navigationService = sl<NavigationService>();

    ScannerCameraViewModel viewModel = sl<ScannerCameraViewModel>();
    viewModel.prepare(widget.campaignId);

    String? infoText;
    return BlocConsumer<ScannerCameraViewModel, ScannerCameraState>(
        bloc: viewModel,
        listener: (context, state) {
          if (state is EntitlementFound) {
            navigationService.pushNamedWithCampaignId(context, ScannerRoutes.scannerEntitlement.name,
                pathParameters: {'entitlementId': state.entitlementId},
                queryParameters: {'checkOnly': _readOnly.toString()});
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
          String? campaignName;

          if (state is ScannerCameraInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerCameraUiLoaded) {
            campaignName = state.campaign.name;
          } else if (state is ScannerCameraError && state.errorType == ScannerCameraErrorType.unknownError) {
            return Center(child: Text(lang.error_load_again));
          } else if (state is ScannerCameraLoading) {
            return centeredProgressIndicator();
          }
          return Padding(
            padding: EdgeInsets.fromLTRB(mediumPadding, 0, mediumPadding, mediumPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kampagne: $campaignName',
                      style: textTheme.headlineSmall!.copyWith(
                        color: colorScheme.onPrimary,
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
                  CameraWidget(
                    readOnly: _readOnly,
                    campaignId: widget.campaignId,
                    onQrCodeFound: (qrCode, campaignId) {
                      viewModel.checkQrCode(qrCode: qrCode, campaignId: campaignId);
                    },
                    infoText: infoText,
                  ),
                  mediumVerticalSpacer(),
                  TextButton(
                    child: Text(
                      'Person manuell suchen',
                      style: textTheme.bodyLarge!.copyWith(
                          color: colorScheme.onPrimary,
                          decoration: TextDecoration.underline,
                          decorationColor: colorScheme.onPrimary),
                    ),
                    onPressed: () {},
                  )
                ],
              ),
            ),
          );
        });
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
