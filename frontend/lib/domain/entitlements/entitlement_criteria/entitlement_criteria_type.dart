enum EntitlementCriteriaType {
  text,
  checkbox,
  float,
  currency,
  integer,
  options,
  unknown;

  static EntitlementCriteriaType fromJson(String value) {
    switch (value) {
      case 'TEXT':
        return EntitlementCriteriaType.text;
      case 'CHECKBOX':
        return EntitlementCriteriaType.checkbox;
      case 'FLOAT':
        return EntitlementCriteriaType.float;
      case 'CURRENCY':
        return EntitlementCriteriaType.currency;
      case 'INTEGER':
        return EntitlementCriteriaType.integer;
      case 'OPTIONS':
        return EntitlementCriteriaType.options;
      default:
        return EntitlementCriteriaType.unknown;
    }
  }

  static String toJson(EntitlementCriteriaType criteriaType) {
    return criteriaType.name.toUpperCase();
  }
}
