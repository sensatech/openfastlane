import 'package:frontend/domain/person/person_model.dart';

/// Do not use for data collections with more than 100 entries
class PersonLocalSearchUtil {
  List<Person> getFilteredPersons(List<Person> persons, String? searchInput) {
    if (searchInput == null || searchInput.isEmpty) return persons;

    List<String> parts = searchInput.split(',');
    List<String> nameKeywords = [];
    late String addressKeyword;

    // Determine if the input has a comma
    if (parts.length > 1) {
      // Handle the case where there's a comma
      nameKeywords = parts[0].trim().split(RegExp(r'\s+')).where((keyword) => keyword.isNotEmpty).toList();
      addressKeyword = parts[1].trim(); // The address keyword is everything after the first comma
    } else {
      // No commas, treat the whole input as name keywords
      nameKeywords = searchInput.split(RegExp(r'\s+')).where((keyword) => keyword.isNotEmpty).toList();
      addressKeyword = parts[0];
      // If there is only one keyword, also use it for the address search
    }

    // Filter the list of persons
    List<Person> filteredPersons = persons.where((person) {
      String firstName = person.firstName.toLowerCase();
      String lastName = person.lastName.toLowerCase();
      String? streetNameNumber = person.address?.streetNameNumber.toLowerCase() ?? '';
      String? addressSuffix = person.address?.addressSuffix.toLowerCase() ?? '';
      String? postalCode = person.address?.postalCode.toLowerCase() ?? '';

      String address = '$streetNameNumber $addressSuffix $postalCode';
      // Check if name keywords match the person's first name or last name
      bool matchesNames = nameKeywords.isEmpty ||
          nameKeywords.every((keyword) {
            keyword = keyword.toLowerCase();
            return firstName.contains(keyword) || lastName.contains(keyword);
          });

      // Check if the address keyword matches the streetNameNumber
      bool matchesAddress = false;
      if (parts.length == 1) {
        matchesAddress = address.contains(addressKeyword.toLowerCase());
      } else {
        matchesAddress = address.contains(addressKeyword.toLowerCase());
      }
      // A person must match all name keywords and, if applicable, the address keyword

      if (parts.length == 1) {
        return matchesNames || matchesAddress;
      }
      return matchesNames && matchesAddress;
    }).toList();

    return filteredPersons;
  }
}
