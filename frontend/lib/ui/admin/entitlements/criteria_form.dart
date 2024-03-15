import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_model.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_option.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_type.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/logger.dart';
import 'package:frontend/ui/admin/commons/input_container.dart';
import 'package:frontend/ui/admin/entitlements/commons.dart';
import 'package:frontend/ui/admin/entitlements/edit_entitlement_vm.dart';
import 'package:frontend/ui/admin/entitlements/text_input_formatters.dart';
import 'package:frontend/ui/admin/persons/edit_person/validators.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class CriteriaForm extends StatefulWidget {
  final Person person;
  final List<EntitlementCause> causes;
  final EntitlementCause selectedCause;
  final EditEntitlementViewModel viewModel;

  const CriteriaForm(
      {super.key, required this.person, required this.selectedCause, required this.causes, required this.viewModel});

  @override
  State<CriteriaForm> createState() => _CriteriaFormState();
}

class _CriteriaFormState extends State<CriteriaForm> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  late List<EntitlementCause> _causes;
  late List<EntitlementCriteria> _selectedCriterias;

  // Maps to hold controllers and states for each criteria
  Map<String, dynamic> _values = {};

  @override
  void initState() {
    super.initState();
    _causes = widget.causes;
    _selectedCriterias = widget.selectedCause.criterias;
    for (var cause in _causes) {
      for (var criteria in cause.criterias) {
        if (criteria.type == EntitlementCriteriaType.text || criteria.type == EntitlementCriteriaType.float) {
          _values[criteria.id] = null;
        } else if (criteria.type == EntitlementCriteriaType.integer) {
          _values[criteria.id] = 1;
        } else if (criteria.type == EntitlementCriteriaType.checkbox) {
          _values[criteria.id] = false;
        } else if (criteria.type == EntitlementCriteriaType.options) {
          _values[criteria.id] = null;
        }
      }
    }
  }

  @override
  void didUpdateWidget(CriteriaForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _autoValidate = false;
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
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(children: [
        ..._selectedCriterias.map((criteria) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: smallSpace),
            child: criteriaSelectionRow(context, criteria.name, field: getCriteriaField(context, criteria)),
          );
        }),
        mediumVerticalSpacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            oflButton(context, lang.back, () {
              context.pop();
            }),
            oflButton(context, lang.save, () {
              if (_formKey.currentState!.validate()) {
                String personId = widget.person.id;
                String entitlementCauseId = widget.selectedCause.id;
                List<EntitlementValue> values = _selectedCriterias.map((criteria) {
                  String value = _values[criteria.id].toString();
                  return EntitlementValue(criteriaId: criteria.id, type: criteria.type, value: value);
                }).toList();
                widget.viewModel
                    .createEntitlement(personId: personId, entitlementCauseId: entitlementCauseId, values: values);
              } else {
                setState(() {
                  _autoValidate = true;
                });
              }
            })
          ],
        )
      ]),
    );
  }

  Widget getCriteriaField(BuildContext context, EntitlementCriteria criteria) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    Logger logger = getLogger();

    late Widget field;
    switch (criteria.type) {
      case EntitlementCriteriaType.text:
        field = personTextFormField(
          context,
          "",
          inputFieldWidth,
          onChanged: (value) {
            _values[criteria.id] = value;
          },
        );
        break;
      case EntitlementCriteriaType.checkbox:
        // Initialize checkbox value to false if not already set
        _values[criteria.id] ??= false;
        field = FormField<bool>(
          initialValue: _values[criteria.id],
          builder: (FormFieldState<bool> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Checkbox(
                    value: _values[criteria.id],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          setState(() {
                            _values[criteria.id] = value;
                          });
                          state.didChange(_values[criteria.id]);
                        });
                      } else {
                        logger.i('checkbox value is null');
                      }
                    },
                  ),
                ),
                if (state.hasError)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      state.errorText!,
                      style: textTheme.bodySmall!.copyWith(color: colorScheme.error),
                    ),
                  ),
              ],
            );
          },
          validator: (value) => validateCheckbox(value, lang),
        );
        break;

      case EntitlementCriteriaType.options:
        // List<EntitlementCriteriaOption>? options = criteria.options;

        // dummy because could not fetch options from API
        List<EntitlementCriteriaOption>? options = [
          const EntitlementCriteriaOption('af001', 'Option 1', 1, null),
          const EntitlementCriteriaOption('af002', 'Option 2', 1, null),
          const EntitlementCriteriaOption('af003', 'Option 3', 1, null),
        ];

        if (options != null) {
          field = FormField<EntitlementCriteriaOption>(
            initialValue: _values[criteria.id],
            builder: (FormFieldState<EntitlementCriteriaOption> state) {
              return Column(
                children: [
                  customInputContainer(
                    width: inputFieldWidth,
                    child: DropdownButton<EntitlementCriteriaOption>(
                      value: _values[criteria.id],
                      onChanged: (EntitlementCriteriaOption? newValue) {
                        setState(() {
                          _values[criteria.id] = newValue;
                        });
                        state.didChange(_values[criteria.id]);
                      },
                      items:
                          options.map<DropdownMenuItem<EntitlementCriteriaOption>>((EntitlementCriteriaOption value) {
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
                  ),
                  if (state.hasError)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(smallSpace),
                        child: Text(
                          state.errorText!,
                          style: textTheme.bodySmall!.copyWith(color: colorScheme.error),
                        ),
                      ),
                    ),
                ],
              );
            },
            validator: (value) => validateCriteriaOptions(value, lang),
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
                    _values[criteria.id].toString(),
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
                        if (_values[criteria.id] != null) {
                          setState(() {
                            _values[criteria.id] = _values[criteria.id]! + 1;
                          });
                        }
                      },
                      hoverColor: Colors.grey,
                      child: Icon(Icons.arrow_upward, size: iconSize),
                    ),
                    InkWell(
                      onTap: () {
                        if (_values[criteria.id] != null && _values[criteria.id]! > 1) {
                          setState(() {
                            _values[criteria.id] = _values[criteria.id]! - 1;
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
          "€",
          inputFieldWidth,
          onChanged: (value) {
            //parse String to float

            _values[criteria.id] = value;
          },
          validator: (value) => validateCurrency(value, lang),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LocaleAwareNumberInputFormatter(),
          ],
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
