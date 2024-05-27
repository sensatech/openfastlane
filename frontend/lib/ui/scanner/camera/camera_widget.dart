// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/logger.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/scanner/camera/scanner_camera_content.dart';
import 'package:logger/logger.dart';
import 'package:zxing_scanner/zxing_scanner.dart';

/// Camera example home widget.
class CameraWidget extends StatefulWidget {
  /// Default Constructor

  final bool checkOnly;
  final String campaignId;
  final String? infoText;
  final CameraDescription camera;
  final CameraController controller;
  final Future<void> initializeControllerFuture;

  final QrCallback onQrCodeFound;

  const CameraWidget({
    super.key,
    required this.checkOnly,
    required this.campaignId,
    this.infoText,
    required this.camera,
    required this.controller,
    required this.initializeControllerFuture,
    required this.onQrCodeFound,
  });

  @override
  State<CameraWidget> createState() {
    return _CameraWidgetState();
  }
}

class _CameraWidgetState extends State<CameraWidget> {
  Logger logger = getLogger();
  bool autoStart = true;
  bool loading = false;

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late bool _flashIsOn;

  String? _lastBarcode;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  final int _pointers = 0;

  @override
  void initState() {
    _controller = widget.controller;
    _initializeControllerFuture = widget.initializeControllerFuture;
    _flashIsOn = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        if (widget.infoText != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
                child: Text(
              widget.infoText!,
              style: textTheme.headlineSmall!.copyWith(color: colorScheme.onPrimary),
            )),
          ),
        _cameraPreviewWidget(),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Expanded(child: SizedBox()),
              scanButton(),
              Expanded(child: Align(alignment: Alignment.centerRight, child: flashButton(_flashIsOn)))
            ]),
          ),
        ),
      ],
    );
  }

  Widget flashButton(bool flashOn) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    IconData iconData = flashOn ? Icons.flash_on : Icons.flash_off;
    Function setFlash = flashOn ? () => setFlashMode(FlashMode.off) : () => setFlashMode(FlashMode.torch);
    return IconButton(
      icon: Icon(iconData, color: colorScheme.onPrimary),
      onPressed: () async {
        setFlash();
      },
    );
  }

  Widget scanButton() {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
          onPressed: () {
            onTakePictureButtonPressed(onScanningFinished: widget.onQrCodeFound);
          },
          child: Center(
            child: (loading)
                ? Padding(
                    padding: EdgeInsets.all(smallPadding),
                    child: const CircularProgressIndicator(),
                  )
                : const Icon(Icons.camera_alt),
          )),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    var maxWidth = MediaQuery.of(context).size.width - 2 * mediumPadding;
    var maxHeight = MediaQuery.of(context).size.height - 400;
    final minMaxSize = min(maxWidth, maxHeight);

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final previewWidth = _controller.value.previewSize!.width;
          final previewHeight = _controller.value.previewSize!.height;
          final previewSize = min(previewWidth, previewHeight);
          return Container(
            width: minMaxSize,
            height: minMaxSize,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: _controller.value.isInitialized ? Colors.green : Colors.white,
                width: 2.0,
              ),
            ),
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: SizedBox(
                    width: previewSize,
                    height: previewSize,
                    child: CameraPreview(
                      _controller,
                      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart: _handleScaleStart,
                          onScaleUpdate: _handleScaleUpdate,
                          onTapDown: (TapDownDetails details) => onViewFinderTap(details, constraints),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                  // green border box:
                                  child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: (_lastBarcode != null) ? Colors.green : Colors.white,
                                    width: 2.0,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container(
            width: minMaxSize,
            height: minMaxSize,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white, width: 2.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                lang.select_camera,
                style: textTheme.headlineMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await _controller.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    appendLog(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.flash_not_supported)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final CameraController cameraController = _controller;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    try {
      cameraController.setExposurePoint(offset);
      cameraController.setFocusPoint(offset);
    } catch (e) {
      logger.w('Error setting exposure or focus point: $e');
    }
    onTakePictureButtonPressed(onScanningFinished: widget.onQrCodeFound);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    return _initializeCameraController(cameraDescription);
  }

  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (cameraController.value.hasError) {
        showInSnackBar('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      trying(() async {
        await cameraController.setFlashMode(FlashMode.off);
      });
      trying(() async {
        // await cameraController.setExposureMode(ExposureMode.auto);
      });
      trying(() async {
        await cameraController.setFocusMode(FocusMode.auto);
      });
      trying(() async {
        _minAvailableZoom = await cameraController.getMinZoomLevel();
        _maxAvailableZoom = await cameraController.getMaxZoomLevel();
        await cameraController.setZoomLevel(_maxAvailableZoom);
      });
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
          break;
      }
    }
  }

  Future<void> trying(Future<void> Function() function) async {
    try {
      await function();
    } catch (e) {
      logger.e('Error: $e', error: e);
    }
  }

  Future<Result?> scanFile(XFile availableImage) async {
    appendLog('scanFile');
    try {
      final bytes = await availableImage.readAsBytes();
      // final result = await decoder.decodeFile(availableImage);
      final results = await scanImage(bytes, maxSize: 600);
      final result = results?.firstOrNull;
      return result;
    } catch (e) {
      logger.e('Error reading barcode: $e', error: e);
      debugPrint('Error reading barcode: $e');
      showInSnackBar('scanFile Error reading barcode: $e');
      return null;
    }
  }

  Future<void> onTakePictureButtonPressed({required QrCallback onScanningFinished}) async {
    setState(() {
      loading = true;
    });
    try {
      var file = await takePicture();

      if (file != null) {
        debugPrint('takePicture: ${file.length}');
        scanFile(file).then((result) {
          if (result != null) {
            debugPrint(result.text);
            _lastBarcode = result.text;
          } else {
            _lastBarcode = null;
            debugPrint('No barcode detected');
          }
          onScanningFinished(_lastBarcode, widget.campaignId, widget.checkOnly);
          setState(() {
            loading = false;
          });
        });
      } else {
        debugPrint('takePicture: file is null');
        showInSnackBar('Error taking picture: no');
      }
    } catch (e) {
      logger.e('Error taking picture: $e', error: e);
      debugPrint('Error taking picture: $e');
      showInSnackBar('Error taking picture: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController cameraController = _controller;
    if (!cameraController.value.isInitialized) {
      debugPrint('takePicture Error: cameraController == null || !cameraController.value.isInitialized');
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      debugPrint('takePicture Error: isTakingPicture');
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('takePicture Error: takePicture $e');
      _showCameraException(e);
      return null;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await _controller.setFlashMode(mode);
      setState(() {
        _flashIsOn = mode == FlashMode.torch;
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    setState(() {
      appendLog(e.description ?? '');
      showInSnackBar('Error: ${e.code}\n${e.description}');
    });
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void appendLog(String message) {
    // logs.add(message);
    // logs.removeRange(0, max(0, logs.length - 4));
    // setState(() {
    //   log = logs.join('\n');
    // });
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }
}
