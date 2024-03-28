import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart'; // Adjusted to CampaignsService
import 'package:frontend/ui/admin/campaign/campaign_selection_vm.dart';
import 'package:mocktail/mocktail.dart';

class MockCampaignsService extends Mock implements CampaignsService {}

class MockCampaign extends Mock implements Campaign {}

void main() {
  late MockCampaignsService mockCampaignsService;
  late CampaignSelectionViewModel campaignSelectionViewModel;

  setUp(() {
    mockCampaignsService = MockCampaignsService();
    campaignSelectionViewModel = CampaignSelectionViewModel(mockCampaignsService);
    // Necessary for verifying method calls on mock objects
    when(() => mockCampaignsService.getCampaigns()).thenAnswer((_) async => <Campaign>[]);
  });

  group('loadCampaigns', () {
    final List<Campaign> campaignsList = [MockCampaign(), MockCampaign(), MockCampaign()];

    blocTest<CampaignSelectionViewModel, CampaignSelectionState>(
      'emits [CampaignSelectionLoading, CampaignSelectionLoaded] when loadCampaigns is called successfully',
      setUp: () {
        when(() => mockCampaignsService.getCampaigns()).thenAnswer((_) async => campaignsList);
      },
      build: () => campaignSelectionViewModel,
      act: (viewModel) => viewModel.loadCampaigns(),
      expect: () => [
        CampaignSelectionLoading(),
        CampaignSelectionLoaded(campaignsList),
      ],
      verify: (_) {
        verify(() => mockCampaignsService.getCampaigns()).called(1);
      },
    );

    blocTest<CampaignSelectionViewModel, CampaignSelectionState>(
      'emits [CampaignSelectionLoading, CampaignSelectionError] when loadCampaigns fails',
      setUp: () {
        when(() => mockCampaignsService.getCampaigns()).thenThrow(Exception('Failed to fetch campaigns'));
      },
      build: () => campaignSelectionViewModel,
      act: (viewModel) => viewModel.loadCampaigns(),
      expect: () => [
        CampaignSelectionLoading(),
        isA<CampaignSelectionError>(),
      ],
      verify: (_) {
        verify(() => mockCampaignsService.getCampaigns()).called(1);
      },
    );
  });
}
