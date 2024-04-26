import 'package:flutter/material.dart';
import 'package:frontend/setup/logger.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

Logger logger = getLogger();

String? formatDateShort(BuildContext context, DateTime? date) {
  if (date == null) {
    return null;
  }
  final Locale appLocale = Localizations.localeOf(context);
  DateFormat dateFormat = DateFormat.yMd(appLocale.toLanguageTag());
  try {
    String formattedDate = dateFormat.format(date);
    return formattedDate;
  } catch (e) {
    return null;
  }
}

String? formatDateTimeShort(BuildContext context, DateTime? date) {
  if (date == null) {
    return null;
  }
  final Locale appLocale = Localizations.localeOf(context);
  DateFormat dateFormat = DateFormat.yMd(appLocale.toLanguageTag()).add_Hm();
  try {
    String formattedDate = dateFormat.format(date);
    return formattedDate;
  } catch (e) {
    return null;
  }
}

String? formatDateLong(BuildContext context, DateTime? date) {
  if (date == null) {
    return null;
  }
  final Locale appLocale = Localizations.localeOf(context);
  DateFormat dateFormat = DateFormat.yMMMd(appLocale.toLanguageTag());
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

String getFormattedDate(DateTime date) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
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
