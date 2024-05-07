import 'package:flutter/material.dart';

Future<void> customDialogBuilder(BuildContext context, String text, Color backgroundColor) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(text, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
      );
    },
  );
}
