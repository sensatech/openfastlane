import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

Widget centeredProgressIndicator({Color? color}) {
  return Padding(
    padding: EdgeInsets.all(mediumPadding),
    child: Center(child: CircularProgressIndicator(color: color)),
  );
}
