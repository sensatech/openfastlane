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
import 'package:frontend/ui/admin/entitlements/create_or_edit_entitlement_vm.dart';
import 'package:frontend/ui/admin/entitlements/currency_input_formatter.dart';
import 'package:frontend/ui/admin/persons/edit_person/validators.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class CriteriaForm extends StatefulWidget {
  final Person person;
  final List<EntitlementCause> causes;
  final EntitlementCause selectedCause;
  final CreateOrEditEntitlementViewModel viewModel;

  const CriteriaForm({super.key, required this.person, required this.selectedCause, required this.causes, required this.viewModel});

  @override
  State<CriteriaForm> createState() => _CriteriaFormState();
}

class _CriteriaFormState extends State<CriteriaForm> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  late List<EntitlementCriteria> _selectedCriterias;

  // Maps to hold controllers and states for each criteria
  Map<String, dynamic> _values = {};

  @override
  void initState() {
    super.initState();
    _selectedCriterias = widget.selectedCause.criterias;
    updateCriteriaValues(_selectedCriterias);
  }

  @override
  void didUpdateWidget(CriteriaForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _autoValidate = false;
    if (widget.selectedCause != oldWidget.selectedCause) {
      setState(() {
        _selectedCriterias = widget.selectedCause.criterias;
      });
      _values = {};
      updateCriteriaValues(_selectedCriterias);
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
            padding: EdgeInsets.symmetric(vertical: smallPadding),
            child: criteriaSelectionRow(context, criteria.name, field: getCriteriaField(context, criteria)),
          );
        }),
        mediumVerticalSpacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OflButton(lang.back, () {
              context.pop();
            }),
            OflButton(lang.save, () {
              if (_formKey.currentState!.validate()) {
                String personId = widget.person.id;
                String entitlementCauseId = widget.selectedCause.id;
                List<EntitlementValue> values = _selectedCriterias.map((criteria) {
                  String value = _values[criteria.id].toString();
                  return EntitlementValue(criteriaId: criteria.id, type: criteria.type, value: value);
                }).toList();
                widget.viewModel.createEntitlement(personId: personId, entitlementCauseId: entitlementCauseId, values: values);
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
          '',
          inputFieldWidth,
          initialValue: _values[criteria.id],
          onChanged: (value) {
            setState(() {
              _values[criteria.id] = value;
            });
          },
        );
        break;
      case EntitlementCriteriaType.checkbox:
        // Initialize checkbox value to false if not already set
        _values[criteria.id] ??= false;
        field = checkBoxField(criteria, logger, textTheme, colorScheme, lang);
        break;

      case EntitlementCriteriaType.options:
        // List<EntitlementCriteriaOption>? options = criteria.options;

        // dummy because could not fetch options from API
        List<EntitlementCriteriaOption>? options = [
          const EntitlementCriteriaOption('af001', 'Option 1', 1, null),
          const EntitlementCriteriaOption('af002', 'Option 2', 1, null),
          const EntitlementCriteriaOption('af003', 'Option 3', 1, null),
        ];

        // can be null, when options are fetched from API
        /*if (options != null) {
          field = optionsField(criteria, options, textTheme, colorScheme, lang);
        } else {
          field = Text(lang.no_options_available);
        }*/
        // remove this line when options are fetched from API
        field = optionsField(criteria, options, textTheme, colorScheme, lang);
        break;

      case EntitlementCriteriaType.integer:
        double iconSize = 20;
        field = integerField(criteria, textTheme, iconSize);
        break;

      case EntitlementCriteriaType.float:
        field = personTextFormField(
          context,
          '€',
          inputFieldWidth,
          onChanged: (value) {
            _values[criteria.id] = value;
          },
          validator: (value) => validateCurrency(value, lang),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
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

  Container integerField(EntitlementCriteria criteria, TextTheme textTheme, double iconSize) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(smallPadding),
      ),
      width: 100,
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: smallPadding, horizontal: mediumPadding),
              child: Text(
                _values[criteria.id].toString(),
                style: textTheme.bodyLarge,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: smallPadding),
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
  }

  FormField<EntitlementCriteriaOption> optionsField(EntitlementCriteria criteria, List<EntitlementCriteriaOption> options,
      TextTheme textTheme, ColorScheme colorScheme, AppLocalizations lang) {
    return FormField<EntitlementCriteriaOption>(
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
                items: options.map<DropdownMenuItem<EntitlementCriteriaOption>>((EntitlementCriteriaOption value) {
                  return DropdownMenuItem<EntitlementCriteriaOption>(
                    value: value,
                    child: Padding(
                      padding: EdgeInsets.all(smallPadding),
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
                  padding: EdgeInsets.all(smallPadding),
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
  }

  FormField<bool> checkBoxField(
      EntitlementCriteria criteria, Logger logger, TextTheme textTheme, ColorScheme colorScheme, AppLocalizations lang) {
    return FormField<bool>(
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
  }

  void updateCriteriaValues(List<EntitlementCriteria> selectedCriterias) {
    for (var criteria in selectedCriterias) {
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
