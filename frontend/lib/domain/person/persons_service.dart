import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/person_search_util.dart';
import 'package:frontend/domain/person/persons_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class PersonsService {
  final PersonsApi _personsApi;
  final CampaignsApi _campaignApi;
  final EntitlementsApi _entitlementsApi;

  PersonsService(this._personsApi, this._campaignApi, this._entitlementsApi);

  Logger logger = getLogger();

  Map<String, Person> _cachedPersons = {};

  // Future<List<Person>> getAllPersons() async {
  //   if (_cachedPersons.isEmpty) {
  //     logger.i('fetching all persons');
  //     var list = await _personsApi.getAllPersons(
  //       withLastConsumptions: true,
  //       withEntitlements: true,
  //     );
  //
  //     _cachedPersons = {for (Person person in list) person.id: person};
  //   }
  //   return _cachedPersons.values.toList();
  // }

  Future<List<Person>> getPersonsFromSearch(String searchQuery) async {
    SearchFilter searchFilter = SearchFilter.getSearchFilter(searchQuery);

    final result = await _personsApi.findPersons(
      firstName: searchFilter.firstName,
      lastName: searchFilter.lastName,
      dateOfBirth: searchFilter.dateOfBirth,
      streetNameNumber: searchFilter.streetNameNumber,
      withLastConsumptions: true,
      withEntitlements: true,
    );
    _cachedPersons = {for (Person person in result) person.id: person};
    return result;
  }

  Future<Person?> getSinglePerson(String personId) async {
    if (_cachedPersons.isNotEmpty) {
      Person? cachedPerson = _cachedPersons[personId];
      if (cachedPerson != null) {
        logger.d('getSinglePerson: return from cache');
        return cachedPerson;
      }
    }

    final Person person = await _personsApi.getPerson(
      personId,
      withLastConsumptions: true,
      withEntitlements: true,
    );

    _cachedPersons[person.id] = person;
    return person;
  }

  Future<List<Entitlement>?> getPersonEntitlements(String personId) async {
    try {
      List<Entitlement> personEntitlements = await _personsApi.getPersonEntitlements(personId);
      List<Entitlement> personEntitlementsWithCampaign = [];
      for (Entitlement entitlement in personEntitlements) {
        Campaign? campaign;
        EntitlementCause? entitlementCause;
        Entitlement entitlementWithCampaign = entitlement;
        if (entitlement.campaign == null) {
          campaign = await _campaignApi.getCampaign(entitlement.campaignId);
        }
        if (entitlement.entitlementCause == null) {
          entitlementCause = await _entitlementsApi.getEntitlementCause(entitlement.entitlementCauseId);
        }
        entitlementWithCampaign = entitlement.copyWith(campaign: campaign, entitlementCause: entitlementCause);
        personEntitlementsWithCampaign.add(entitlementWithCampaign);
      }
      return personEntitlementsWithCampaign;
    } catch (e) {
      logger.e('Error while fetching entitlements for person $personId: $e');
      return null;
    }
  }

  Future<List<AuditItem>?> getPersonHistory(String personId) async {
    try {
      return await _personsApi.getPersonAuditHistory(personId);
    } catch (e) {
      logger.e('Error while fetching getPersonHistory for person $personId: $e');
      return null;
    }
  }

  Future<List<Person>> getSimilarPersons(String firstName, String lastName, DateTime dateOfBirth) async {
    logger.i('fetching similar persons');
    return _personsApi.findSimilarPersons(firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth);
  }

  Future<Person> updatePerson(
    String id, {
    String? firstName,
    String? lastName,
    Gender? gender,
    DateTime? dateOfBirth,
    String? streetNameNumber,
    String? addressSuffix,
    String? postalCode,
    String? email,
    String? mobileNumber,
    String? comment,
  }) {
    logger.i('fetching similar persons');
    return _personsApi.patchPerson(
      id,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      streetNameNumber: streetNameNumber,
      addressSuffix: addressSuffix,
      postalCode: postalCode,
      email: email,
      mobileNumber: mobileNumber,
      comment: comment,
    );
  }

  Future<Person> createPerson({
    required String firstName,
    required String lastName,
    required Gender gender,
    required DateTime dateOfBirth,
    required String streetNameNumber,
    required String addressSuffix,
    required String postalCode,
    String? email,
    String? mobileNumber,
    String? comment,
  }) {
    return _personsApi.postPerson(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        streetNameNumber: streetNameNumber,
        addressSuffix: addressSuffix,
        postalCode: postalCode,
        email: email,
        mobileNumber: mobileNumber,
        comment: comment);
  }

  Future<void> invalidateCache(String personId) async {
    _cachedPersons.remove(personId);
    await getSinglePerson(personId);
  }

  Future<void> invalidateCaches() async {
    _cachedPersons.clear();
  }
}

class SearchResult {
  final String searchQuery;
  final bool success;
  final int? size;
  final List<Person>? persons;

  SearchResult({
    required this.searchQuery,
    required this.success,
    this.size,
    this.persons,
  });
}
