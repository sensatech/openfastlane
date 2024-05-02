/*
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class ScannerCameraTestVM extends Cubit<ScannerCameraTestState> {
  ScannerCameraTestVM() : super(CameraInitial());
  final Logger logger = getLogger();

  Future<void> prepare() async {
    try {
      emit(CamerasLoaded());
    } on CameraException catch (e) {
      logger.e('Cannot get cameras: $e', error: e);
      emit(CamerasError(e));
    }
  }
}

class ScannerCameraTestState {}

class CameraInitial extends ScannerCameraTestState {}

class CamerasLoaded extends ScannerCameraTestState {
  CamerasLoaded();
}

class CamerasError extends ScannerCameraTestState {
  CamerasError(this.error);

  final Exception error;
}
*/
