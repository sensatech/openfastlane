class Person {
  final String id;
  final Gender gender;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String street;
  final String streetNumber;
  final String? stairNumber;
  final String doorNumber;
  final String city;
  final String zip;
  final String addressId;
  final DateTime birthdate;

  Person(
      this.id,
      this.gender,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.street,
      this.streetNumber,
      this.stairNumber,
      this.doorNumber,
      this.city,
      this.zip,
      this.addressId,
      this.birthdate);
}

enum Gender { male, female, diverse }
