import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/commons/values/currency_format.dart';
import 'package:frontend/ui/commons/values/date_format.dart';

String? validateName(String value, AppLocalizations lang) {
  if (value.isEmpty) {
    return lang.field_must_not_be_empty;
  } else {
    return null;
  }
}

String? validateDate(String value, BuildContext context) {
  AppLocalizations lang = AppLocalizations.of(context)!;
  // Regular expression pattern for the German date format (dd.mm.yyyy)
  DateTime? dateTime = getFormattedDateTime(context, value);
  DateTime? strictDateTime = getFormattedStrictDateTime(context, value);

  if (value.isEmpty) {
    // If the value is empty, return an error message.
    return lang.field_must_not_be_empty;
  }
  // check if year is less than 1900, to avoid checking for unrealistic duplicates (e.g. year 1 or 19)
  else if (dateTime == null || dateTime.year < 1900) {
    // If the value doesn't match the required format, return an error message.
    return lang.invalid_date_format;
  } else if (dateTime.isAfter(DateTime.now())) {
    return lang.date_in_future;
  } else if (strictDateTime == null) {
    return lang.invalid_date;
  } else {
    return null;
  }
}

String? validateNumber(String value, AppLocalizations lang) {
  if (value.isEmpty) {
    return lang.field_must_not_be_empty;
  } else if (double.tryParse(value) == null) {
    return lang.invalid_number;
  } else {
    return null;
  }
}

String? validateDataProcessingCheckbox(bool? value, AppLocalizations lang) {
  if (value == false) {
    return lang.must_accept_terms_data_processing;
  } else {
    return null;
  }
}


String? validateCurrency(String value, AppLocalizations lang) {
  if (value.isEmpty) {
    return lang.field_must_not_be_empty;
  } else if (parseCurrencyStringToDouble(value) == null) {
    return lang.invalid_number;
  } else {
    return null;
  }
}

String? validateCriteriaOptions(String? optionValue, AppLocalizations lang) {
  if (optionValue == null) {
    return lang.field_must_not_be_empty;
  }
  return null;
}

String? validateEmailAndPhoneNumber(ContactDetails? contactDetails, AppLocalizations lang) {
  if (contactDetails == null || (contactDetails.email == null && contactDetails.mobileNumber == null)) {
    return lang.please_enter_valid_email_or_mobile;
  }

  if (contactDetails.email != null && contactDetails.email!.isNotEmpty) {
    // Validate email format
    RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(contactDetails.email!)) {
      return lang.invalid_mail_format;
    }
  }

  if (contactDetails.mobileNumber != null && contactDetails.mobileNumber!.isNotEmpty) {
    // Validate phone number format
    RegExp phoneRegex = RegExp(r'^\+?\d{4,}$');
    if (!phoneRegex.hasMatch(contactDetails.mobileNumber!)) {
      return lang.invalid_mobile_format;
    }
  }

  return null;
}

class ContactDetails {
  final String? mobileNumber;
  final String? email;

  ContactDetails({required this.mobileNumber, required this.email});
}
