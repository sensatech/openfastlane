import 'package:flutter/material.dart';
import 'package:frontend/setup/logger.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

Logger logger = getLogger();

String? getFormattedDateAsString(BuildContext context, DateTime date) {
  final Locale appLocale = Localizations.localeOf(context);
  DateFormat dateFormat = DateFormat.yMd(appLocale.toLanguageTag());
  try {
    String formattedDate = dateFormat.format(date);
    return formattedDate;
  } catch (e) {
    return null;
  }
}

DateTime? getFormattedDateTime(BuildContext context, String string) {
  final Locale appLocale = Localizations.localeOf(context);
  DateFormat dateFormat = DateFormat.yMd(appLocale.toLanguageTag());
  try {
    DateTime date = dateFormat.parse(string);
    return date;
  } catch (e) {
    logger.e('Error parsing date: $e');
    return null;
  }
}

DateTime? getFormattedStrictDateTime(BuildContext context, String string) {
  final Locale appLocale = Localizations.localeOf(context);
  DateFormat dateFormat = DateFormat.yMd(appLocale.toLanguageTag());
  try {
    DateTime date = dateFormat.parseStrict(string);
    return date;
  } catch (e) {
    logger.e('Error parsing date: $e');
    return null;
  }
}
