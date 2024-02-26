import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getFormattedDate(BuildContext context, DateTime date) {
  final Locale appLocale = Localizations.localeOf(context);
  DateFormat dateFormat = DateFormat.yMd(appLocale.toLanguageTag());
  return dateFormat.format(date);
}
