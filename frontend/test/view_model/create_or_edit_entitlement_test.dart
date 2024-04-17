import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_entitlement_vm.dart';
import 'package:mocktail/mocktail.dart';

import 'campaign_selection_vm_test.dart';

// mocked services
class MockEntitlementsService extends Mock implements EntitlementsService {}

class MockPersonsService extends Mock implements PersonsService {}

class MockGlobalUserService extends Mock implements GlobalUserService {}

class MockCampaignService extends Mock implements CampaignsService {}

// mocked models

void main() {
  late MockEntitlementsService mockEntitlementsService;
  late MockPersonsService mockPersonsService;
  late MockGlobalUserService mockGlobalUserService;
  late MockCampaignsService mockCampaignsService;
  late CreateEntitlementViewModel viewModel;

  setUp(() {
    mockEntitlementsService = MockEntitlementsService();
    mockPersonsService = MockPersonsService();
    mockGlobalUserService = MockGlobalUserService();
    mockCampaignsService = MockCampaignsService();
    viewModel = CreateEntitlementViewModel(
      mockEntitlementsService,
      mockPersonsService,
      mockCampaignsService,
    );
  });

  group('prepare', () {
    final mockPerson = createPerson();
    const mockCampaign = Campaign('', '', Period.daily, []);
    const mockEntitlementCause = EntitlementCause('', '', '', [], null);
    final mockEntitlementCauseList = [mockEntitlementCause, mockEntitlementCause, mockEntitlementCause];

    blocTest<CreateEntitlementViewModel, CreateEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementLoaded] on successful preparation',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockPersonsService.getSinglePerson(any())).thenAnswer((_) async => mockPerson);
        when(() => mockEntitlementsService.getEntitlementCauses()).thenAnswer((_) async => mockEntitlementCauseList);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId', 'campaignId'),
      expect: () => [
        CreateEntitlementLoading(),
        isA<CreateEntitlementLoaded>(),
      ],
      verify: (_) {
        verify(() => mockPersonsService.getSinglePerson(any())).called(1);
        verify(() => mockEntitlementsService.getEntitlementCauses()).called(1);
      },
    );

    blocTest<CreateEntitlementViewModel, CreateEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementError] when campaign is null',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(null);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId', 'campaignId'),
      expect: () => [
        CreateEntitlementLoading(),
        isA<CreateEditEntitlementError>(),
      ],
    );

    blocTest<CreateEntitlementViewModel, CreateEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementError] when person is null',
      setUp: () {
        when(() => mockPersonsService.getSinglePerson(any())).thenAnswer((_) async => null);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId', 'campaignId'),
      expect: () => [
        CreateEntitlementLoading(),
        isA<CreateEditEntitlementError>(),
      ],
    );

    blocTest<CreateEntitlementViewModel, CreateEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementError] on exception in try-catch block',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockEntitlementsService.getEntitlementCauses()).thenThrow(Exception('Error fetching person'));
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId', 'campaignId'),
      expect: () => [
        CreateEntitlementLoading(),
        isA<CreateEditEntitlementError>(),
      ],
    );
  });

  group('prepareForEdit', () {
    final mockPerson = createPerson();
    const mockCampaign = Campaign('', '', Period.daily, []);
    final mockEntitlement = createEntitlement();
    const mockEntitlementCause = EntitlementCause('', '', '', [], null);
    final mockEntitlementCauseList = [mockEntitlementCause, mockEntitlementCause, mockEntitlementCause];

    blocTest<CreateEntitlementViewModel, CreateEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementLoaded] when preparation for edit is successful',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockPersonsService.getSinglePerson(any())).thenAnswer((_) async => mockPerson);
        when(() => mockEntitlementsService.getEntitlement(any())).thenAnswer((_) async => mockEntitlement);
        when(() => mockEntitlementsService.getEntitlementCauses()).thenAnswer((_) async => mockEntitlementCauseList);
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId', 'entitlementId'),
      expect: () => [CreateEntitlementLoading(), isA<CreateEntitlementLoaded>()],
      verify: (_) {
        verify(() => mockPersonsService.getSinglePerson(any())).called(1);
        verify(() => mockEntitlementsService.getEntitlementCauses()).called(1);
      },
    );

    blocTest<CreateEntitlementViewModel, CreateEntitlementState>(
      'emits [CreateOrEditEntitlementLoading, CreateOrEditEntitlementError] when an exception occurs',
      setUp: () {
        when(() => mockGlobalUserService.currentCampaign).thenReturn(mockCampaign);
        when(() => mockPersonsService.getSinglePerson(any())).thenThrow(Exception('Failed to fetch person'));
      },
      build: () => viewModel,
      act: (viewModel) => viewModel.prepare('personId', 'entitlementId'),
      expect: () => [CreateEntitlementLoading(), isA<CreateEditEntitlementError>()],
    );
  });

  group('createEntitlement', () {
    final mockEntitlement = createEntitlement();
    final mockPerson = createPerson();
    const mockCampaign = Campaign('', '', Period.daily, []);
    const mockEntitlementCause = EntitlementCause('', '', '', [], null);
    final mockEntitlementCauseList = [mockEntitlementCause, mockEntitlementCause, mockEntitlementCause];

    blocTest<CreateEntitlementViewModel, CreateEntitlementState>(
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
      expect: () => [isA<CreateEntitlementEdited>(), CreateEntitlementCompleted()],
      verify: (_) {
        verify(() => mockPersonsService.getSinglePerson(any())).called(1);
        verify(() => mockEntitlementsService.createEntitlement(any(), any(), any())).called(1);
      },
    );

    blocTest<CreateEntitlementViewModel, CreateEntitlementState>(
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
      expect: () => [isA<CreateEditEntitlementError>()],
    );
  });
}

Person createPerson() {
  return Person(
    '',
    '',
    '',
    DateTime.now(),
    Gender.male,
    null,
    '',
    '',
    '',
    const [],
    DateTime.now(),
    DateTime.now(),
    const [],
    const [],
  );
}

Entitlement createEntitlement() {
  return Entitlement(
      id: '',
      personId: '',
      entitlementCauseId: '',
      values: const [],
      campaignId: '',
      confirmedAt: DateTime.now(),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now(),
      updatedAt: DateTime.now());
}
