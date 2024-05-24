import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/reports/download_file.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';
import 'package:universal_html/html.dart';

class EntitlementViewViewModel extends Cubit<EntitlementViewState> {
  EntitlementViewViewModel(this._entitlementsService, this._personsService, this._campaignService) : super(EntitlementViewInitial());

  final EntitlementsService _entitlementsService;
  final PersonsService _personsService;
  final CampaignsService _campaignService;
  Logger logger = getLogger();

  Future<void> loadEntitlement(String entitlementId) async {
    emit(EntitlementViewLoading());
    try {
      Entitlement entitlement = await _entitlementsService.getEntitlement(entitlementId);
      EntitlementCause entitlementCause = await _entitlementsService.getEntitlementCause(entitlement.entitlementCauseId);
      Campaign campaign = await _campaignService.getCampaign(entitlementCause.campaignId);

      Person? person = await _personsService.getSinglePerson(entitlement.personId);
      List<Consumption>? consumptions = await _entitlementsService.getEntitlementConsumptions(entitlement.id);
      ConsumptionPossibility consumptionPossibility = await _entitlementsService.canConsume(entitlement.id);
      List<AuditItem>? auditLogs = await _entitlementsService.getAuditHistory(entitlement.id);

      if (person != null) {
        logger.i('Entitlement loaded: $entitlement');
        EntitlementInfo entitlementInfo = EntitlementInfo(
          entitlement: entitlement,
          cause: entitlementCause,
          person: person,
          campaignName: campaign.name,
          consumptions: consumptions,
          auditLogs: auditLogs,
          consumptionPossibility: consumptionPossibility,
        );
        emit(EntitlementViewLoaded(entitlementInfo));
      } else {
        logger.e('Error loading entitlement - person: $person');
        emit(EntitlementViewError('Error loading entitlement: person of entitlement is null'));
      }
    } catch (e) {
      logger.e('Error loading entitlement: $e');
      emit(EntitlementViewError(e.toString()));
    }
  }

  Future<void> extendEntitlement(String entitlementId) async {
    emit(EntitlementValidationLoading());
    try {
      await _entitlementsService.extend(entitlementId);
    } catch (e) {
      emit(EntitlementValidationError(e.toString()));
    }
    loadEntitlement(entitlementId);
  }

  Future<DownloadFile?> getQrPdf(String entitlementId) async {
    try {
      final DownloadFile? file = await _entitlementsService.getQrPdf(entitlementId);
      if (file == null || file.content.isEmpty) {
        return null;
      }
      final base64data = base64Encode(file.content);
      final dataType = file.contentType ?? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      final link = AnchorElement(href: 'data:$dataType;base64,$base64data');

      logger.i('prepareReportDownload: create link for ${file.fileName} $dataType');

      link.download = file.fileName;
      link.click();

      logger.d('prepareReportDownload: iterating $file persons');
      return file;
    } catch (e) {
      return null;
    }
  }

  Future<void> performConsume(String entitlementId) async {
    emit(EntitlementValidationLoading());
    try {
      await _entitlementsService.performConsume(entitlementId);
    } catch (e) {
      emit(EntitlementValidationError(e.toString()));
    }
    loadEntitlement(entitlementId);
  }

}

@immutable
abstract class EntitlementViewState extends Equatable {}

class EntitlementViewInitial extends EntitlementViewState {
  @override
  List<Object?> get props => [];
}

class EntitlementViewLoading extends EntitlementViewState {
  @override
  List<Object?> get props => [];
}

class EntitlementViewLoaded extends EntitlementViewState {
  EntitlementViewLoaded(this.entitlementInfo);

  final EntitlementInfo entitlementInfo;

  @override
  List<Object?> get props => [entitlementInfo];
}

class EntitlementViewError extends EntitlementViewState {
  EntitlementViewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class EntitlementValidationLoading extends EntitlementViewState {
  @override
  List<Object?> get props => [];
}

class EntitlementValidationError extends EntitlementViewState {
  EntitlementValidationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class EntitlementInfo {
  final Entitlement entitlement;
  final EntitlementCause cause;
  final Person person;
  final String campaignName;
  final List<Consumption>? consumptions;
  final List<AuditItem>? auditLogs;
  final ConsumptionPossibility? consumptionPossibility;

  EntitlementInfo({
    required this.entitlement,
    required this.cause,
    required this.person,
    required this.campaignName,
    this.consumptions,
    this.auditLogs,
    this.consumptionPossibility,
  });
}
