import 'package:flutter/material.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  String? _campaignId;

  void updateCampaignId(String campaignId) {
    _campaignId = campaignId;
  }

  // get campaign Id
  String? get campaignId => _campaignId;

  void goNamedWithCampaignId(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? pathParameters,
  }) {
    context.goNamed(routeName,
        queryParameters: _finalizeQueryParameter(queryParameters),
        pathParameters: _finalizePathParameter(pathParameters));
  }

  Future<T?> pushNamedWithCampaignId<T extends Object?>(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? pathParameters,
  }) {
    return context.pushNamed(routeName,
        queryParameters: _finalizeQueryParameter(queryParameters),
        pathParameters: _finalizePathParameter(pathParameters));
  }

  void replaceNamedWithCampaignId<T extends Object?>(BuildContext context, String routeName,
      {Map<String, dynamic>? queryParameters, Map<String, String>? pathParameters}) {
    return context.pushReplacementNamed(routeName,
        queryParameters: _finalizeQueryParameter(queryParameters),
        pathParameters: _finalizePathParameter(pathParameters));
  }

  void goToCameraPage(BuildContext context, bool? checkOnly) {
    replaceNamedWithCampaignId(context, ScannerRoutes.scannerCamera.name,
        queryParameters: _finalizeQueryParameter({'checkOnly': checkOnly.toString()}));
  }

  Map<String, dynamic> _finalizeQueryParameter(Map<String, dynamic>? queryParameters) {
    final params = queryParameters ?? {};
    if (_campaignId != null) {
      params['campaignId'] = _campaignId!;
    }
    return params;
  }

  Map<String, String> _finalizePathParameter(Map<String, String>? pathParameters) => pathParameters ?? {};
}
