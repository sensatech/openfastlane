import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:mocktail/mocktail.dart';

class MockPersonService extends Mock implements PersonsService {}

void main() {
  late MockPersonService mockPersonService;
  late AdminPersonListViewModel adminPersonListViewModel;

  setUp(() {
    mockPersonService = MockPersonService();
    adminPersonListViewModel = AdminPersonListViewModel(mockPersonService);
  });

  group('fetchDevices()', () {
    const Address address = Address('name + number', 'suffix', 'zip', '123', '123');
    final Person person = Person('123', 'Peter', 'Meyer', DateTime.now(), Gender.male, address, 'email@email.com',
        '06601234567', 'comment', const ['123', '123'], DateTime.now(), DateTime.now());
    final PersonWithEntitlementsInfo personWithEntitlementsInfo =
        PersonWithEntitlementsInfo(person, DateTime.now(), DateTime.now()); // Mock data
    final List<PersonWithEntitlementsInfo> listPersonWithEntitlementsInfo = [
      personWithEntitlementsInfo,
      personWithEntitlementsInfo,
      personWithEntitlementsInfo
    ];

    blocTest<AdminPersonListViewModel, AdminPersonListState>(
      'emits [AdminPersonListLoading, AdminPersonListLoaded] when loadAllPersons is called successfully',
      setUp: () {
        when(() => mockPersonService.getAllPersonsWithInfo()).thenAnswer((_) async => listPersonWithEntitlementsInfo);
      },
      build: () => adminPersonListViewModel,
      act: (AdminPersonListViewModel cubit) => cubit.loadAllPersons(),
      expect: () => <AdminPersonListState>[
        AdminPersonListLoading(),
        AdminPersonListLoaded(listPersonWithEntitlementsInfo),
      ],
      verify: (_) async {
        verify(() => mockPersonService.getAllPersonsWithInfo()).called(1);
      },
    );
  });
}
