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

class PersonListViewModel extends Bloc<PersonListEvent, PersonListState> {
  final PersonsService _personService;
  final CampaignsService _campaignsService;

  Logger logger = getLogger();

  PersonListViewModel(this._personService, this._campaignsService) : super(PersonListInitial()) {
    on<LoadAllPersonsWithEntitlementsEvent>(
      (event, emit) async {
        emit(PersonListLoading());
        String? campaignName;
        try {
          List<Person> persons = [];
          if (event.campaignId != null) {
            Campaign campaign = await _campaignsService.getCampaign(event.campaignId!);
            campaignName = campaign.name;
          }
          if (event.searchQuery != null) {
            logger.i('loading persons with search query: ${event.searchQuery}');
            persons = await _personService.getPersonsFromSearch(event.searchQuery!);
            emit(PersonListLoaded(persons, campaignName: campaignName));
          } else {
            logger.i('loading all persons');
            persons = await _personService.getAllPersons();

            emit(PersonListLoaded(persons, campaignName: campaignName));
          }

          logger.i('${persons.length} persons loaded in vm');
        } catch (e) {
          emit(PersonListError(e.toString()));
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
abstract class PersonListEvent {}

class LoadAllPersonsWithEntitlementsEvent extends PersonListEvent {
  LoadAllPersonsWithEntitlementsEvent({this.campaignId, this.searchQuery});

  final String? campaignId;
  final String? searchQuery;
}

@immutable
abstract class PersonListState extends Equatable {}

class PersonListInitial extends PersonListState {
  @override
  List<Object> get props => [];
}

class PersonListLoading extends PersonListState {
  @override
  List<Object> get props => [];
}

class PersonListLoaded extends PersonListState {
  PersonListLoaded(this.persons, {this.campaignName});

  final List<Person> persons;
  final String? campaignName;

  @override
  List<Object> get props => [persons];
}

class PersonListError extends PersonListState {
  PersonListError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
