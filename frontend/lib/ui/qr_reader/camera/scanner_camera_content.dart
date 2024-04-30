import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/qr_reader/camera/camera_widget.dart';
import 'package:frontend/ui/qr_reader/camera/scanner_camera_vm.dart';

class ScannerCameraContent extends StatefulWidget {
  const ScannerCameraContent({super.key, required this.campaignId});

  final String campaignId;

  @override
  State<ScannerCameraContent> createState() => _ScannerCameraContentState();
}

class _ScannerCameraContentState extends State<ScannerCameraContent> {
  bool _readOnly = true;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    ScannerCameraViewModel viewModel = sl<ScannerCameraViewModel>();
    viewModel.prepare(widget.campaignId);
    return BlocBuilder<ScannerCameraViewModel, ScannerCameraState>(
        bloc: viewModel,
        builder: (context, state) {
          String? campaignName;

          if (state is ScannerCameraInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerCameraUiLoaded) {
            campaignName = state.campaign.name;
          } else if (state is ScannerCameraError) {
            return Center(child: Text(lang.error_load_again));
          } else if (state is ScannerCameraLoading) {
            return centeredProgressIndicator();
          }
          return Padding(
            padding: EdgeInsets.all(largeSpace),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kampagne: $campaignName',
                      style: TextStyle(
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
                  CameraWidget(readOnly: _readOnly),
                  mediumVerticalSpacer(),
                  TextButton(
                    child: Text(
                      'Person manuell suchen',
                      style: TextStyle(
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
