import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/transformers.dart';

// We're using BLoC instead of Cubit in this class because we need to leverage the transformer property of BLoC.
// This ensures that the event is restartable and prevents multiple simultaneous events, crucial for detecting duplicates
// based on dynamic user input. With input changing dynamically with each new letter typed into a text field,
// previous input becomes obsolete.

class AdminPersonListViewModel extends Bloc<AdminPersonListEvent, AdminPersonListState> {
  final PersonsService _personService;
  final CampaignsService _campaignsService;

  Logger logger = getLogger();

  AdminPersonListViewModel(this._personService, this._campaignsService) : super(AdminPersonListInitial()) {
    on<LoadAllPersonsWithEntitlementsEvent>(
      (event, emit) async {
        emit(AdminPersonListLoading());
        String? campaignName;
        try {
          List<Person> persons = [];
          if (event.searchQuery != null) {
            logger.i('loading persons with search query: ${event.searchQuery}');
            persons = await _personService.getPersonsFromSearch(event.searchQuery!);
            emit(AdminPersonListLoaded(persons, campaignName: campaignName));
          } else {
            logger.i('loading all persons');
            persons = await _personService.getAllPersons();
            if (event.campaignId != null) {
              Campaign campaign = await _campaignsService.getCampaign(event.campaignId!);
              campaignName = campaign.name;
            }
            emit(AdminPersonListLoaded(persons, campaignName: campaignName));
          }

          logger.i('${persons.length} persons loaded in vm');
        } catch (e) {
          emit(AdminPersonListError(e.toString()));
        }
      },
      transformer: debounceRestartable(const Duration(milliseconds: 1000)),
    );
  }

  EventTransformer<T> debounceRestartable<T>(Duration duration) {
    return (events, mapper) {
      return events.debounceTime(duration).switchMap(mapper);
    };
  }
}

@immutable
abstract class AdminPersonListEvent {}

class LoadAllPersonsWithEntitlementsEvent extends AdminPersonListEvent {
  LoadAllPersonsWithEntitlementsEvent({this.campaignId, this.searchQuery});

  final String? campaignId;
  final String? searchQuery;
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
