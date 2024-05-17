import 'package:flutter/material.dart';
import 'package:frontend/ofl_app.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {

  await dotenv.load(fileName: 'dotenv');
  final dotenvConfig = EnvConfig.fromDotenv();
  setupDependencies(dotenvConfig);
  runApp(const OflApp());
}
