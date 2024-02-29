enum EntitlementCriteriaType {
  text,
  checkbox,
  options,
  integer,
  float,
  unknown;

  static EntitlementCriteriaType fromJson(String value) {
    switch (value) {
      case 'TEXT':
        return EntitlementCriteriaType.text;
      case 'CHECKBOX':
        return EntitlementCriteriaType.checkbox;
      case 'OPTIONS':
        return EntitlementCriteriaType.options;
      case 'INTEGER':
        return EntitlementCriteriaType.integer;
      case 'FLOAT':
        return EntitlementCriteriaType.float;
      default:
        return EntitlementCriteriaType.unknown;
    }
  }

  static String toJson(EntitlementCriteriaType criteriaType) {
    return criteriaType.name.toUpperCase();
  }
}
