import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/person_search_util.dart';
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

  Campaign? _campaign;

  PersonListViewModel(this._personService, this._campaignsService) : super(PersonListInitial()) {
    on<LoadAllPersonsWithEntitlementsEvent>(
      (event, emit) async {
        emit(PersonListLoading());
        try {
          SearchFilter searchFilter = SearchFilter.getSearchFilter(event.searchQuery);

          if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
            logger.i('loading persons with search query: ${event.searchQuery}');
            List<Person> persons = await _personService.getPersonsFromSearch(searchFilter);
            logger.i('${persons.length} persons loaded in view model');

            if (persons.length > 100) {
              emit(
                  PersonListTooMany(campaignName: _campaign?.name, searchFilter: searchFilter, length: persons.length));
            } else {
              emit(PersonListLoaded(campaignName: _campaign?.name, searchFilter: searchFilter, persons: persons));
            }
          } else {
            logger.w('loading all persons with invalid search query ${event.searchQuery}');
            emit(PersonListEmpty(campaignName: _campaign?.name, searchFilter: searchFilter));
          }
        } catch (e) {
          logger.e('error loading persons: $e');
          emit(PersonListError(e.toString()));
        }
      },
      transformer: debounceRestartable(const Duration(milliseconds: 600)),
    );

    on<InitPersonListEvent>((event, emit) async {
      emit(PersonListInitial());
    });
  }

  Future<void> prepare(String? campaignId) async {
    if (campaignId != null) {
      logger.i('loading campaign from campaign id $campaignId');
      _campaign = await _campaignsService.getCampaign(campaignId);
    }
  }

  EventTransformer<T> debounceRestartable<T>(Duration duration) {
    return (events, mapper) {
      return events.debounceTime(duration).switchMap(mapper);
    };
  }
}

@immutable
abstract class PersonListEvent extends Equatable {}

class LoadAllPersonsWithEntitlementsEvent extends PersonListEvent {
  LoadAllPersonsWithEntitlementsEvent({
    this.searchQuery,
  });

  final String? searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

class InitPersonListEvent extends PersonListEvent {
  @override
  List<Object> get props => [];
}

@immutable
abstract class PersonListState extends Equatable {
  String? get campaignName;
}

class PersonListInitial extends PersonListState {
  @override
  List<Object> get props => [];

  @override
  String? get campaignName => null;
}

class PersonListLoading extends PersonListState {
  @override
  List<Object> get props => [];

  @override
  String? get campaignName => null;
}

class PersonListTooMany extends PersonListState {
  PersonListTooMany({this.campaignName, required this.searchFilter, required this.length});

  @override
  final String? campaignName;

  final SearchFilter searchFilter;

  final int length;

  @override
  List<Object?> get props => [campaignName, searchFilter, length];
}

class PersonListEmpty extends PersonListState {
  PersonListEmpty({this.campaignName, required this.searchFilter});

  @override
  final String? campaignName;

  final SearchFilter searchFilter;

  @override
  List<Object?> get props => [campaignName, searchFilter];
}

class PersonListLoaded extends PersonListState {
  PersonListLoaded({
    this.campaignName,
    required this.searchFilter,
    required this.persons,
  });

  @override
  final String? campaignName;

  final List<Person> persons;

  final SearchFilter searchFilter;

  @override
  List<Object?> get props => [campaignName, searchFilter];
}

class PersonListError extends PersonListState {
  PersonListError(this.error);

  final String error;

  @override
  String? get campaignName => null;

  @override
  List<Object> get props => [error];
}
