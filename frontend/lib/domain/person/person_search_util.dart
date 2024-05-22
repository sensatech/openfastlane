

import 'package:equatable/equatable.dart';

class SearchFilter extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? streetNameNumber;

  final String? postalCode;

  const SearchFilter({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.streetNameNumber,
    this.postalCode,
  });

  static SearchFilter getSearchFilter(String? searchInput) {
    if (searchInput == null || searchInput.isEmpty) return const SearchFilter();

    String? firstName;
    String? lastName;
    String? dateOfBirth;
    String? streetNameNumber;
    String? postalCode;

    List<String> parts = searchInput.split(',');

    // Determine if the input has a comma
    if (parts.isNotEmpty) {
      final namesPart = parts[0].trim();
      final names = namesPart.split(RegExp(r'\s+')).where((keyword) => keyword.isNotEmpty).toList();
      firstName = names.isNotEmpty ? names[0].trim() : null;
      lastName = names.length > 1 ? names[1].trim() : null;
      dateOfBirth = names.length > 2 ? names[2].trim() : null;
    }

    if (parts.length > 1) {
      streetNameNumber = parts[1].trim();
    }

    if (parts.length > 2) {
      postalCode = parts[2].trim();
    }

    return SearchFilter(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      streetNameNumber: streetNameNumber,
      postalCode: postalCode,
    );
  }

  @override
  List<Object?> get props => [firstName, lastName, dateOfBirth, streetNameNumber, postalCode];
}
