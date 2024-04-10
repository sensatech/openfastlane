import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:mocktail/mocktail.dart';

class MockPersonsService extends Mock implements PersonsService {}

class MockEntitlementsService extends Mock implements EntitlementsService {}

class MockGlobalUserService extends Mock implements GlobalUserService {}

void main() {
  late MockPersonsService mockPersonsService;
  late MockEntitlementsService mockEntitlementsService;
  late AdminPersonListViewModel adminPersonListViewModel;

  setUp(() {
    mockPersonsService = MockPersonsService();
    mockEntitlementsService = MockEntitlementsService();
    adminPersonListViewModel = AdminPersonListViewModel(
      mockPersonsService,
      mockEntitlementsService,
    );
  });

  group('loadAllPersons()', () {
    final Person person = Person(
        '123',
        'John',
        'Doe',
        DateTime.now(),
        Gender.male,
        const Address('name + number', 'suffix', 'zip', '123', '123'),
        'email@example.com',
        '1234567890',
        'A comment',
        const [],
        DateTime.now(),
        DateTime.now());
    final List<Person> personsList = [person];
    const Entitlement entitlement = Entitlement(id: '1', entitlementCauseId: '123', personId: '123', values: []);
    final List<Entitlement> entitlementsList = [entitlement];
    const EntitlementCause entitlementCause = EntitlementCause('123', 'name', '123', [], null);
    final List<EntitlementCause> entitlementCausesList = [entitlementCause];
    final List<PersonWithEntitlement> personWithEntitlementsList = [PersonWithEntitlement(person, entitlementsList)];

    blocTest<AdminPersonListViewModel, AdminPersonListState>(
      'emits [AdminPersonListLoading, AdminPersonListLoaded] when loadAllPersons is called successfully',
      setUp: () {
        when(mockPersonsService.getAllPersons).thenAnswer((_) async => personsList);
        when(mockEntitlementsService.getEntitlements).thenAnswer((_) async => entitlementsList);
        when(mockEntitlementsService.getEntitlementCauses).thenAnswer((_) async => entitlementCausesList);
      },
      build: () => adminPersonListViewModel,
      act: (viewModel) => viewModel.loadAllPersons(),
      expect: () => [
        AdminPersonListLoading(),
        AdminPersonListLoaded(personWithEntitlementsList, entitlementCausesList),
      ],
      verify: (_) {
        verify(mockPersonsService.getAllPersons).called(1);
        verify(mockEntitlementsService.getEntitlements).called(1);
        verify(mockEntitlementsService.getEntitlementCauses).called(1);
      },
    );
  });
}
