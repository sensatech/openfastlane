import 'package:logger/logger.dart';

Logger getLogger() {
  return Logger(
    printer: PrettyPrinter(
      lineLength: 110,
      colors: true,
      methodCount: 0,
      errorMethodCount: 5,
    ),
  );
}
