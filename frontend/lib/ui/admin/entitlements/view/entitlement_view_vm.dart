import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/abstract_api.dart';
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
import 'package:frontend/ui/admin/commons/exceptions.dart';
import 'package:frontend/ui/admin/entitlements/view/mail_result.dart';
import 'package:logger/logger.dart';
import 'package:universal_html/html.dart';

class EntitlementViewViewModel extends Cubit<EntitlementViewState> {
  EntitlementViewViewModel(this._entitlementsService, this._personsService, this._campaignService)
      : super(EntitlementViewInitial());

  final EntitlementsService _entitlementsService;
  final PersonsService _personsService;
  final CampaignsService _campaignService;
  Logger logger = getLogger();

  late EntitlementInfo entitlementInfo;
  late String entitlementId;

  //actually, loaded just once:
  EntitlementCause? _entitlementCause;
  Campaign? _campaign;
  Person? _person;

  Future<void> loadEntitlement(String entitlementId) async {
    this.entitlementId = entitlementId;
    emit(EntitlementViewLoading());
    try {
      Entitlement entitlement = await _entitlementsService.getEntitlement(entitlementId);
      // load once
      _entitlementCause ??= await _entitlementsService.getEntitlementCause(entitlement.entitlementCauseId);
      _campaign ??= await _campaignService.getCampaign(_entitlementCause!.campaignId);
      _person ??= await _personsService.getSinglePerson(entitlement.personId);
      // load every time
      List<Consumption>? consumptions = await _entitlementsService.getEntitlementConsumptions(entitlement.id);
      ConsumptionPossibility consumptionPossibility = await _entitlementsService.canConsume(entitlement.id);
      List<AuditItem>? auditLogs = await _entitlementsService.getAuditHistory(entitlement.id);

      if (_person != null) {
        logger.i('Entitlement loaded: $entitlement');
        entitlementInfo = EntitlementInfo(
          entitlement: entitlement,
          cause: _entitlementCause!,
          person: _person!,
          campaignName: _campaign!.name,
          consumptions: consumptions,
          auditLogs: auditLogs,
          consumptionPossibility: consumptionPossibility,
        );
        emit(EntitlementViewLoaded(entitlementInfo));
      } else {
        logger.e('Error loading entitlement - person is null');
        emit(EntitlementViewError(UiException(UiErrorType.personNotFound)));
      }
    } on Exception catch (e) {
      logger.e('Error loading entitlement: $e');
      emit(EntitlementViewError(e));
    }
  }

  Future<void> extendEntitlement() async {
    emit(EntitlementValidationLoading());
    try {
      await _entitlementsService.extend(entitlementId);
    } on Exception catch (e) {
      emit(EntitlementValidationError(e));
    }
    loadEntitlement(entitlementId);
  }

  Future<DownloadFile?> getQrPdf() async {
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
    } on Exception catch (e) {
      logger.e('Error while getQrPdf: $e', error: e);
      return null;
    }
  }

  Future<void> performConsume() async {
    emit(EntitlementViewLoading());
    try {
      await _entitlementsService.performConsume(entitlementId);
    } on Exception catch (e) {
      emit(EntitlementValidationError(e));
    }
    loadEntitlement(entitlementId);
  }

  Future<MailResult> sendQrPdf(String recipient) async {
    emit(EntitlementViewLoading());

    final MailResult result = await _sendQrForMailResult(recipient);
    emit(EntitlementViewLoaded(entitlementInfo));

    return result;
  }

  Future<MailResult> _sendQrForMailResult(String recipient) async {
    try {
      final finalRecipient = recipient.isNotEmpty ? recipient : null;
      logger.i('sendQrPdf: send with finalRecipient $finalRecipient');
      await _entitlementsService.sendQrPdf(entitlementId, finalRecipient);
      return MailResult(true);
    } on ApiException catch (e) {
      logger.e('ApiException while sendQrPdf: $e', error: e);
      return MailResult(false, errorMessage: e.errorMessage, exception: e);
    } on Exception catch (e) {
      logger.e('Exception while sendQrPdf: $e', error: e);
      return MailResult(false, errorMessage: e.toString());
    }
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
  EntitlementViewError(this.error);

  final Exception error;

  @override
  List<Object?> get props => [error];
}

class EntitlementValidationLoading extends EntitlementViewState {
  @override
  List<Object?> get props => [];
}

class EntitlementValidationError extends EntitlementViewState {
  EntitlementValidationError(this.error);

  final Exception error;

  @override
  List<Object?> get props => [error];
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
