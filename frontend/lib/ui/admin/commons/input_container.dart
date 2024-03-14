import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

Widget customInputContainer({
  double? width,
  required Widget child,
}) {
  return Container(
    width: width,
    decoration: BoxDecoration(
      border: Border.all(), // Border color
      borderRadius: BorderRadius.circular(smallSpace), // Border radius
    ),
    child: child,
  );
}

Widget personTextFormField(BuildContext context, String hintText, double width,
    {String? Function(String)? validator, TextEditingController? controller, void Function(String)? onChanged}) {
  return SizedBox(
    width: width,
    child: TextFormField(
      controller: controller,
      validator: (text) => (text != null && validator != null) ? validator(text) : null,
      decoration: InputDecoration(
          hintText: hintText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(smallSpace))),
      onChanged: onChanged,
    ),
  );
}
