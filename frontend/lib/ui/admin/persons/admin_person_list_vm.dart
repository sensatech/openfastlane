import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class AdminPersonListViewModel extends Cubit<AdminPersonListState> {
  AdminPersonListViewModel(this._personService, this._campaignsService) : super(AdminPersonListInitial());

  final PersonsService _personService;
  final CampaignsService _campaignsService;

  Logger logger = getLogger();

  Future<void> loadAllPersonsWithEntitlements({String? campaignId}) async {
    emit(AdminPersonListLoading());
    String? campaignName;
    try {
      List<Person> persons = await _personService.getAllPersons();
      if (campaignId != null) {
        Campaign campaign = await _campaignsService.getCampaign(campaignId);
        campaignName = campaign.name;
      }

      logger.d('loadAllPersons: iterating ${persons.length} persons');

      emit(AdminPersonListLoaded(persons, campaignName: campaignName));
    } catch (e) {
      emit(AdminPersonListError(e.toString()));
    }
  }
}

@immutable
abstract class AdminPersonListState extends Equatable {}

class AdminPersonListInitial extends AdminPersonListState {
  @override
  List<Object> get props => [];
}

class AdminPersonListLoading extends AdminPersonListState {
  @override
  List<Object> get props => [];
}

class AdminPersonListLoaded extends AdminPersonListState {
  AdminPersonListLoaded(this.persons, {this.campaignName});

  final List<Person> persons;
  final String? campaignName;

  @override
  List<Object> get props => [persons];
}

class AdminPersonListError extends AdminPersonListState {
  AdminPersonListError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

// good idea! We might use that generally, so we can think about using that in the service
class PersonWithEntitlement extends Equatable {
  final Person person;

  const PersonWithEntitlement(this.person);

  @override
  List<Object> get props => [person];
}
