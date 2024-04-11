// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zxing_scanner/zxing_scanner.dart';

import 'package:frontend/setup/logger.dart';

typedef QrCallback = void Function(String? qr);

/// Camera example home widget.
class CameraWidget extends StatefulWidget {
  /// Default Constructor

  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() {
    return _CameraWidgetState();
  }
}

class _CameraWidgetState extends State<CameraWidget> {
  Logger logger = getLogger();
  late final AppLifecycleListener _listener;
  CameraController? _controller;

  bool working = false;
  bool autoStart = true;

  bool loading = false;

  String? lastBarcode;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
      onExitRequested: _onExitRequested,
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  void _onStateChanged(AppLifecycleState value) {
    switch (value) {
      case AppLifecycleState.detached:
        stopCamera();
      case AppLifecycleState.resumed:
        if (autoStart) {
          startCamera();
        } else {}
      case AppLifecycleState.inactive:
        stopCamera();
      case AppLifecycleState.hidden:
        stopCamera();
      case AppLifecycleState.paused:
        stopCamera();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> startCamera() async {
    if (_controller != null && _controller!.value.isInitialized) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      final cameras = await availableCameras();
      final bestCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      await _initializeCameraController(bestCamera);
      setState(() {});
    } on CameraException catch (e) {
      working = false;
      _showCameraException(e);
    }
    setState(() {
      loading = false;
    });
  }

  void stopCamera() {
    setState(() {
      loading = true;
    });
    _controller?.stopImageStream();
    _controller?.dispose();
    _controller = null;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _controller != null && _controller!.value.isInitialized;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: (lastBarcode == null)
                ? Text(
                    lastBarcode ?? 'Bitte QR-Code scannen',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  )
                : Text(
                    lastBarcode!,
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
          ),
        ),
        _cameraPreviewWidget(),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                onPressed: () {
                  if (active) {
                    stopCamera();
                  } else {
                    startCamera();
                  }
                },
                child: Text(active ? 'Stop' : 'Start'),
              ),
              ElevatedButton(
                onPressed: onTakePictureButtonPressed,
                child: Row(
                  children: [
                    (loading) ? const CircularProgressIndicator() : const Icon(Icons.camera_alt),
                    const Text('Scannen'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  onSetFlashModeButtonPressed(FlashMode.torch);
                },
                child: const Icon(Icons.flash_on),
              ),
              ElevatedButton(
                onPressed: () {
                  onSetFlashModeButtonPressed(FlashMode.off);
                },
                child: const Icon(Icons.flash_off),
              ),
            ]),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(8),
        //   child: Center(
        //     child: Text(
        //       log,
        //       softWrap: true,
        //       overflow: TextOverflow.clip,
        //       maxLines: 5,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = _controller;
    var size = MediaQuery.of(context).size.width;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container(
          width: size / 2,
          height: size / 3,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 2.0),
          ),
          child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Kamera auswählen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                  ))));
    } else {
      final previewWidth = _controller!.value.previewSize!.width;
      final previewHeight = _controller!.value.previewSize!.height;
      final previewSize = min(previewWidth, previewHeight) / 2;
      return Listener(
          onPointerDown: (_) => _pointers++,
          onPointerUp: (_) => _pointers--,
          child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: _controller!.value.isInitialized ? Colors.green : Colors.white,
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
                                _controller!,
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
                                              color: (lastBarcode != null) ? Colors.green : Colors.white,
                                              width: 2.0,
                                            ),
                                          ),
                                        )),
                                      ],
                                    ),
                                  );
                                }),
                              )))))));
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await _controller!.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    appendLog(message);
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_controller == null) {
      return;
    }

    final CameraController cameraController = _controller!;

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
    onTakePictureButtonPressed();
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      return _controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
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
      setState(() {
        working = true;
      });
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
      setState(() {
        working = false;
      });
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

  Future<void> onTakePictureButtonPressed() async {
    setState(() {
      loading = true;
    });
    try {
      var file = await takePicture();

      if (file != null) {
        debugPrint('takePicture: ${file.length}');
        scanFile(file).then((result) {
          // Code result = await zx.readBarcodeImagePath(availableImage);
          if (result != null) {
            debugPrint(result.text);
            showInSnackBar('ZX: ${result.text}');
            lastBarcode = result.text;
          } else {
            lastBarcode = null;
            debugPrint('No barcode detected');
            showInSnackBar('ZX: No barcode detected');
          }
          loading = false;
          setState(() {});
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
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
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

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null) {
      return;
    }

    try {
      await _controller!.setFlashMode(mode);
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

  Future<AppExitResponse> _onExitRequested() async {
    stopCamera();
    return AppExitResponse.exit;
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
