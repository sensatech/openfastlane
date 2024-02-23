import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String? validateName(String value, AppLocalizations lang) {
  if (value.isEmpty) {
    return lang.field_must_not_be_empty;
  } else {
    return null;
  }
}

String? validateDate(String value, AppLocalizations lang) {
  // Regular expression pattern for the German date format (dd.mm.yyyy)
  RegExp dateRegex = RegExp(r'^\d{2}\.\d{2}.\d{4}$');

  if (value.isEmpty) {
    // If the value is empty, return an error message.
    return lang.field_must_not_be_empty;
  } else if (!dateRegex.hasMatch(value)) {
    // If the value doesn't match the required format, return an error message.
    return lang.hint_date_format;
  } else {
    // Splitting the date string into day, month, and year components
    List<String> dateComponents = value.split('.');
    int day = int.tryParse(dateComponents[0]) ?? 0;
    int month = int.tryParse(dateComponents[1]) ?? 0;
    int year = int.tryParse(dateComponents[2]) ?? 0;

    // Checking if the date components form a valid date
    if (day < 1 || day > 31 || month < 1 || month > 12) {
      return lang.invalid_date;
    }

    // Checking for February and leap years
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (day > 29 || (day == 29 && !isLeapYear)) {
        return lang.invalid_date;
      }
    }

    // Checking for months with 30 days
    if ([4, 6, 9, 11].contains(month) && day > 30) {
      return lang.invalid_date;
    }

    // If the value is not empty and matches the required format and is a valid date, return null indicating the input is valid.
    return null;
  }
}

String? validateNumber(String value, AppLocalizations lang) {
  if (value.isEmpty) {
    return lang.field_must_not_be_empty;
  } else if (int.tryParse(value) == null) {
    return lang.invalid_number;
  } else {
    return null;
  }
}

String? validateCheckbox(bool? value, AppLocalizations lang) {
  if (value == false) {
    return lang.must_accept_terms_data_processing;
  } else {
    return null;
  }
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
    RegExp phoneRegex = RegExp(r'^\+?\d{1,3}[- ]?\d{3}[- ]?\d{3}[- ]?\d{3}$');
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
