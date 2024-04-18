import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_type.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  setupDependencies(configLocal);

  group('EntitlementValue Extension', () {
    // Tests for typeValue method
    group('typeValue', () {
      test('returns null when value is "null"', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: 'null', type: EntitlementCriteriaType.text);
        expect(entitlementValue.typeValue, isEmpty);
      });

      test('returns string for text type with a (normal) string value', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: 'some text', type: EntitlementCriteriaType.text);
        expect(entitlementValue.typeValue, equals('some text'));
      });

      test('returns true for checkbox type with value "true"', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: 'true', type: EntitlementCriteriaType.checkbox);
        expect(entitlementValue.typeValue, isTrue);
      });

      test('returns false for checkbox type with value "false"', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: 'false', type: EntitlementCriteriaType.checkbox);
        expect(entitlementValue.typeValue, isFalse);
      });

      test('returns false for checkbox type with "null" value', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: 'null', type: EntitlementCriteriaType.checkbox);
        expect(entitlementValue.typeValue, isFalse);
      });

      test('returns 0 for integer type with "null" value', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: 'null', type: EntitlementCriteriaType.integer);
        expect(entitlementValue.typeValue, equals(0));
      });

      test('returns int number for integer type with in number value', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: '123', type: EntitlementCriteriaType.integer);
        expect(entitlementValue.typeValue, equals(123));
      });

      test('returns 0.0 for float type with "null" value', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: 'null', type: EntitlementCriteriaType.float);
        expect(entitlementValue.typeValue, equals(0.0));
      });

      test('returns double number for float type with double number value', () {
        var entitlementValue =
            const EntitlementValue(criteriaId: 'criteriaId', value: '123.542', type: EntitlementCriteriaType.float);
        expect(entitlementValue.typeValue, equals(123.542));
      });
    });
  });
}
