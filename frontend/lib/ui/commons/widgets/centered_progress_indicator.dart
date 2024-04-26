import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

Widget centeredProgressIndicator() {
  return Padding(
    padding: EdgeInsets.all(mediumPadding),
    child: const Center(child: CircularProgressIndicator()),
  );
}
