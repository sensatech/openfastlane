import 'package:flutter/material.dart';
import 'package:frontend/ofl_app.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/setup/setup_dependencies.dart';

void main() {
  setupDependencies(configStaging);
  runApp(const OflApp());
}
