import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/ui/admin/entitlements/create_or_edit_entitlement_vm.dart';
import 'package:mocktail/mocktail.dart';

// mocked services
class MockEntitlementsService extends Mock implements EntitlementsService {}

class MockPersonsService extends Mock implements PersonsService {}

class MockGlobalUserService extends Mock implements GlobalUserService {}

// mocked models

void main() {
  late MockEntitlementsService mockEntitlementsService;
  late MockPersonsService mockPersonsService;
  late MockGlobalUserService mockGlobalUserService;
  late CreateOrEditEntitlementViewModel viewModel;

  setUp(() {
    mockEntitlementsService = MockEntitlementsService();
    mockPersonsService = MockPersonsService();
    mockGlobalUserService = MockGlobalUserService();
    viewModel = CreateOrEditEntitlementViewModel(
      mockEntitlementsService,
      mockPersonsService,
      mockGlobalUserService,
    );
  });

  group('prepare', () {
    final mockPerson =
        Person('', '', '', DateTime.now(), Gender.male, null, '', '', '', const [], DateTime.now(), DateTime.now());
    const mockCampaign = Campaign('', '', Period.daily, []);
    const mockEntitlementCause = EntitlementCause('', '', '', [], null);
    final mockEntitlementCauseList = [mockEntitlementCause, mockEntitlementCause, mockEntitlementCause];

    blocTest<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementLoaded] on successful preparation',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockPersonsService.getSinglePerson(any())).thenAnswer((_) async => mockPerson);
        when(() => mockEntitlementsService.getEntitlementCauses()).thenAnswer((_) async => mockEntitlementCauseList);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId'),
      expect: () => [
        CreateOrEditEntitlementLoading(),
        isA<CreateOrEditEntitlementLoaded>(),
      ],
      verify: (_) {
        verify(() => mockPersonsService.getSinglePerson(any())).called(1);
        verify(() => mockEntitlementsService.getEntitlementCauses()).called(1);
      },
    );

    blocTest<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementError] when campaign is null',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(null);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId'),
      expect: () => [
        CreateOrEditEntitlementLoading(),
        isA<CreateOrEditEntitlementError>(),
      ],
    );

    blocTest<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementError] when person is null',
      setUp: () {
        when(() => mockPersonsService.getSinglePerson(any())).thenAnswer((_) async => null);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId'),
      expect: () => [
        CreateOrEditEntitlementLoading(),
        isA<CreateOrEditEntitlementError>(),
      ],
    );

    blocTest<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementError] on exception in try-catch block',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockEntitlementsService.getEntitlementCauses()).thenThrow(Exception('Error fetching person'));
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId'),
      expect: () => [
        CreateOrEditEntitlementLoading(),
        isA<CreateOrEditEntitlementError>(),
      ],
    );
  });

  group('prepareForEdit', () {
    final mockPerson =
        Person('', '', '', DateTime.now(), Gender.male, null, '', '', '', const [], DateTime.now(), DateTime.now());
    const mockCampaign = Campaign('', '', Period.daily, []);
    const mockEntitlement = Entitlement(id: '', personId: '', entitlementCauseId: '', values: []);
    const mockEntitlementCause = EntitlementCause('', '', '', [], null);
    final mockEntitlementCauseList = [mockEntitlementCause, mockEntitlementCause, mockEntitlementCause];

    blocTest<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementLoaded] when preparation for edit is successful',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockPersonsService.getSinglePerson(any())).thenAnswer((_) async => mockPerson);
        when(() => mockEntitlementsService.getEntitlement(any())).thenAnswer((_) async => mockEntitlement);
        when(() => mockEntitlementsService.getEntitlementCauses()).thenAnswer((_) async => mockEntitlementCauseList);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepareForEdit('personId', 'entitlementId'),
      expect: () => [CreateOrEditEntitlementLoading(), isA<CreateOrEditEntitlementLoaded>()],
      verify: (_) {
        verify(() => mockPersonsService.getSinglePerson(any())).called(1);
        verify(() => mockEntitlementsService.getEntitlementCauses()).called(1);
      },
    );

    blocTest<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementError] when an exception occurs',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockPersonsService.getSinglePerson(any())).thenThrow(Exception('Failed to fetch person'));
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepareForEdit('personId', 'entitlementId'),
      expect: () => [CreateOrEditEntitlementLoading(), isA<CreateOrEditEntitlementError>()],
    );
  });

  group('createEntitlement', () {
    const mockEntitlement = Entitlement(id: '', personId: '', entitlementCauseId: '', values: []);
    final mockPerson =
        Person('', '', '', DateTime.now(), Gender.male, null, '', '', '', const [], DateTime.now(), DateTime.now());
    const mockCampaign = Campaign('', '', Period.daily, []);
    const mockEntitlementCause = EntitlementCause('', '', '', [], null);
    final mockEntitlementCauseList = [mockEntitlementCause, mockEntitlementCause, mockEntitlementCause];

    blocTest<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
      'emits [CreateOrEntitlementEdited, CreateOrEntitlementCompleted] when entitlement is successfully created',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockPersonsService.getSinglePerson(any())).thenAnswer((_) async => mockPerson);
        when(() => mockEntitlementsService.getEntitlement(any())).thenAnswer((_) async => mockEntitlement);
        when(() => mockEntitlementsService.getEntitlementCauses()).thenAnswer((_) async => mockEntitlementCauseList);
        when(() => mockEntitlementsService.createEntitlement(any(), any(), any()))
            .thenAnswer((_) async => mockEntitlement);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.createEntitlement(
        personId: 'personId',
        entitlementCauseId: 'causeId',
        values: [],
      ),
      expect: () => [isA<CreateOrEntitlementEdited>(), CreateOrEntitlementCompleted()],
      verify: (_) {
        verify(() => mockPersonsService.getSinglePerson(any())).called(1);
        verify(() => mockEntitlementsService.createEntitlement(any(), any(), any())).called(1);
      },
    );

    blocTest<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
      'emits [CreateOrEditEntitlementError] when there is an error creating the entitlement',
      setUp: () {
        when(() => mockEntitlementsService.createEntitlement(any(), any(), any()))
            .thenThrow(Exception('Error creating entitlement'));
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.createEntitlement(
        personId: 'personId',
        entitlementCauseId: 'causeId',
        values: [],
      ),
      expect: () => [isA<CreateOrEditEntitlementError>()],
    );
  });
}
