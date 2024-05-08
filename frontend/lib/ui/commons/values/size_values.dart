import 'package:flutter/material.dart';

Widget smallVerticalSpacer() {
  return const SizedBox(height: 8);
}

Widget mediumVerticalSpacer() {
  return const SizedBox(height: 16);
}

Widget largeVerticalSpacer() {
  return const SizedBox(height: 32);
}

Widget extraLargeVerticalSpacer() {
  return const SizedBox(height: 64);
}

Widget smallHorizontalSpacer() {
  return const SizedBox(width: 8);
}

Widget mediumHorizontalSpacer() {
  return const SizedBox(width: 16);
}

Widget largeHorizontalSpacer() {
  return const SizedBox(width: 32);
}

Widget extraLargeHorizontalSpacer() {
  return const SizedBox(width: 64);
}

TableRow rowSpacer() {
  return const TableRow(children: [
    SizedBox(
      height: 8,
    ),
    SizedBox(
      height: 8,
    )
  ]);
}

//value
double smallPadding = 8;
double mediumPadding = 16;
double largeSpace = 32;
double extraLargeSpace = 64;

//form field widths
double smallFormFieldWidth = 200;
double mediumFormFieldWidth = 300;
double largeFormFieldWidth = 400;

//widgets
double buttonHeight = 50;
