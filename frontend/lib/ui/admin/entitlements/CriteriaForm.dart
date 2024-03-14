import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_model.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_option.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_type.dart';
import 'package:frontend/ui/admin/commons/inupt_container.dart';
import 'package:frontend/ui/admin/entitlements/commons.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';

class CriteriaForm extends StatefulWidget {
  final List<EntitlementCause> causes;
  final EntitlementCause selectedCause;

  const CriteriaForm({super.key, required this.selectedCause, required this.causes});

  @override
  State<CriteriaForm> createState() => _CriteriaFormState();
}

class _CriteriaFormState extends State<CriteriaForm> {
  final _formKey = GlobalKey<FormState>();

  late List<EntitlementCause> _causes;
  late List<EntitlementCriteria> _selectedCriterias;

  // Maps to hold controllers and states for each criteria
  Map<String, String?> _textValues = {};
  Map<String, bool> _checkboxValues = {};
  Map<String, EntitlementCriteriaOption?> _dropdownCriteriaOptions = {};
  Map<String, int> _intValues = {};

  @override
  void initState() {
    super.initState();
    _causes = widget.causes;
    _selectedCriterias = widget.selectedCause.criterias;
    // Initialize controllers and states for each criteria
    for (var cause in _causes) {
      for (var criteria in cause.criterias) {
        if (criteria.type == EntitlementCriteriaType.text || criteria.type == EntitlementCriteriaType.float) {
          _textValues[criteria.id] = null;
        } else if (criteria.type == EntitlementCriteriaType.integer) {
          _intValues[criteria.id] = 1;
        } else if (criteria.type == EntitlementCriteriaType.checkbox) {
          _checkboxValues[criteria.id] = false;
        } else {
          _dropdownCriteriaOptions[criteria.id] = null;
        }
      }
    }
  }

  @override
  void didUpdateWidget(CriteriaForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCause != oldWidget.selectedCause) {
      setState(() {
        _selectedCriterias = widget.selectedCause.criterias;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(children: [
        ..._selectedCriterias.map((criteria) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: smallSpace),
            child: criteriaSelectionRow(context, criteria.name, field: getCriteriaField(context, criteria)),
          );
        }).toList(),
        mediumVerticalSpacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [oflButton(context, lang.back, () {}), oflButton(context, lang.save, () {})],
        )
      ]),
    );
  }

  Widget getCriteriaField(BuildContext context, EntitlementCriteria criteria) {
    TextTheme textTheme = Theme.of(context).textTheme;

    late Widget field;
    switch (criteria.type) {
      case EntitlementCriteriaType.text:
        field = personTextFormField(context, "", inputFieldWidth, onChanged: (value) {
          _textValues[criteria.id] = value;
        });
        break;
      case EntitlementCriteriaType.checkbox:
        // Initialize checkbox value to false if not already set
        _checkboxValues[criteria.id] ??= false;
        field = Align(
          alignment: Alignment.centerLeft,
          child: Checkbox(
            value: _checkboxValues[criteria.id],
            onChanged: (bool? value) {
              setState(() {
                _checkboxValues[criteria.id] = value!;
              });
            },
          ),
        );
        break;

      case EntitlementCriteriaType.options:
        List<EntitlementCriteriaOption>? options = criteria.options;
        if (options != null) {
          // Placeholder options
          field = customInputContainer(
            width: inputFieldWidth,
            child: DropdownButton<EntitlementCriteriaOption>(
              value: _dropdownCriteriaOptions[criteria.id],
              onChanged: (EntitlementCriteriaOption? newValue) {
                setState(() {
                  _dropdownCriteriaOptions[criteria.id] = newValue;
                });
              },
              items: options.map<DropdownMenuItem<EntitlementCriteriaOption>>((EntitlementCriteriaOption value) {
                return DropdownMenuItem<EntitlementCriteriaOption>(
                  value: value,
                  child: Padding(
                    padding: EdgeInsets.all(smallSpace),
                    child: Text(value.label, style: textTheme.bodyLarge),
                  ),
                );
              }).toList(),
              isExpanded: true,
              underline: const SizedBox(),
            ),
          );
        } else {
          field = const Text('keine Optionen verfügbar');
        }
        break;

      case EntitlementCriteriaType.integer:
        double iconSize = 20;
        field = Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(smallSpace),
          ),
          width: 100,
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: smallSpace, horizontal: mediumSpace),
                  child: Text(
                    _intValues[criteria.id].toString(),
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: smallSpace),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if (_intValues[criteria.id] != null) {
                          setState(() {
                            _intValues[criteria.id] = _intValues[criteria.id]! + 1;
                          });
                        }
                      },
                      hoverColor: Colors.grey,
                      child: Icon(Icons.arrow_upward, size: iconSize),
                    ),
                    InkWell(
                      onTap: () {
                        if (_intValues[criteria.id] != null && _intValues[criteria.id]! > 1) {
                          setState(() {
                            _intValues[criteria.id] = _intValues[criteria.id]! - 1;
                          });
                        }
                      },
                      child: Icon(Icons.arrow_downward, size: iconSize),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
        break;

      case EntitlementCriteriaType.float:
        field = personTextFormField(
          context,
          "",
          inputFieldWidth,
        );
        break;
      default:
        field = const SizedBox();
        break;
    }
    return SizedBox(
      width: inputFieldWidth,
      child: field,
    );
  }
}
