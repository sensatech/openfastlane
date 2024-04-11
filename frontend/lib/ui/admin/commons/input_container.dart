import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

Widget customInputContainer({
  double? width,
  required Widget child,
}) {
  return Container(
    width: width,
    decoration: BoxDecoration(
      border: Border.all(), // Border color
      borderRadius: BorderRadius.circular(smallPadding), // Border radius
    ),
    child: child,
  );
}

Widget personTextFormField(BuildContext context, String hintText, double width,
    {String? initialValue,
    String? Function(String)? validator,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    void Function(String)? onChanged}) {
  return SizedBox(
    width: width,
    child: TextFormField(
      initialValue: initialValue,
      controller: controller,
      validator: (text) => (text != null && validator != null) ? validator(text) : null,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          hintText: hintText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(smallPadding))),
      onChanged: onChanged,
    ),
  );
}
