import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_model.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_type.dart';

void main() {
  group('EntitlementCriteria', () {
    test('fromJson() should properly deserialize JSON', () {
      const jsonString = '''
        {
          "id" : "65ccc7b155e16444da78c8f3",
          "name" : "Entitlement Name",
          "type" : "TEXT"
        }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final EntitlementCriteria criteria = EntitlementCriteria.fromJson(jsonMap);

      expect(criteria.id, '65ccc7b155e16444da78c8f3');
      expect(criteria.name, 'Entitlement Name');
      expect(criteria.type, EntitlementCriteriaType.text);
    });

    test('toJson() should properly serialize object to JSON', () {
      const criteria =
          EntitlementCriteria('65ccc7b155e16444da78c8f3', 'Entitlement Name', EntitlementCriteriaType.text, null);

      final Map<String, dynamic> jsonMap = criteria.toJson();

      expect(jsonMap['id'], '65ccc7b155e16444da78c8f3');
      expect(jsonMap['name'], 'Entitlement Name');
      expect(jsonMap['type'], 'TEXT');
    });
  });
}
