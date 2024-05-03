import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_status.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:mocktail/mocktail.dart';

class MockPersonsService extends Mock implements PersonsService {}

class MockCampaignsService extends Mock implements CampaignsService {}

class MockGlobalUserService extends Mock implements GlobalUserService {}

void main() {
  late MockPersonsService mockPersonsService;
  late MockCampaignsService mockCampaignsService;
  late AdminPersonListViewModel adminPersonListViewModel;

  setUp(() {
    mockPersonsService = MockPersonsService();
    mockCampaignsService = MockCampaignsService();
    adminPersonListViewModel = AdminPersonListViewModel(
      mockPersonsService,
      mockCampaignsService,
    );
  });

  group('loadAllPersons()', () {
    Entitlement entitlement = Entitlement(
      id: '1',
      entitlementCauseId: '123',
      personId: '123',
      values: const [],
      campaignId: '123',
      confirmedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      audit: const [],
      status: EntitlementStatus.valid,
    );
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
      DateTime.now(),
      [entitlement],
      const [],
    );
    final List<Person> personsList = [person];
    const Campaign campaign = Campaign('123', 'name', Period.daily, []);

    blocTest<AdminPersonListViewModel, AdminPersonListState>(
      'emits [AdminPersonListLoading, AdminPersonListLoaded] when loadAllPersons is called successfully',
      setUp: () {
        when(() => mockPersonsService.getAllPersons()).thenAnswer((_) async => personsList);
        when(() => mockCampaignsService.getCampaign('campaign-001')).thenAnswer((_) async => campaign);
      },
      build: () => adminPersonListViewModel,
      act: (viewModel) => viewModel.add(LoadAllPersonsWithEntitlementsEvent(campaignId: '123')),
      expect: () => [
        AdminPersonListLoading(),
        AdminPersonListLoaded(personsList),
      ],
      verify: (_) {
        verify(mockPersonsService.getAllPersons).called(1);
      },
    );
  });
}
