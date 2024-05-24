import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_model.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_option.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_type.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/logger.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/input_container.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/commons.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/currency_input_formatter.dart';
import 'package:frontend/ui/admin/persons/edit_person/validators.dart';
import 'package:frontend/ui/commons/values/currency_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class CriteriaForm extends StatefulWidget {
  final Person person;
  final List<EntitlementCause> causes;
  final EntitlementCause selectedCause;
  final Entitlement? entitlement;
  final Function(String personId, String entitlementCauseId, List<EntitlementValue> values) createOrEditEntitlement;

  const CriteriaForm(
      {super.key,
      required this.person,
      required this.selectedCause,
      required this.causes,
      this.entitlement,
      required this.createOrEditEntitlement});

  @override
  State<CriteriaForm> createState() => _CriteriaFormState();
}

class _CriteriaFormState extends State<CriteriaForm> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  late List<EntitlementCriteria> _selectedCriterias;

  // Maps to hold controllers and states for each criteria
  Map<String, String> _values = {};

  @override
  void initState() {
    super.initState();
    _selectedCriterias = widget.selectedCause.criterias;
    if (widget.entitlement != null) {
      updateCriteriaValues(widget.entitlement!);
    } else {
      initializeCriteriaValues(_selectedCriterias);
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
      _values = {};
      initializeCriteriaValues(_selectedCriterias);
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
            child: criteriaSelectionRow(
              context,
              criteria.name,
              child: SizedBox(
                width: inputFieldWidth,
                child: getCriteriaField(context, criteria),
              ),
            ),
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
                widget.createOrEditEntitlement(personId, entitlementCauseId, values);
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

    CurrencyInputFormatter currencyFormatter = sl<CurrencyInputFormatter>();
    String? criteriaValue = _values[criteria.id];

    switch (criteria.type) {
      case EntitlementCriteriaType.text:
        String initialValue = getTextValue(criteriaValue);
        return personTextFormField(
          context,
          '',
          inputFieldWidth,
          initialValue: initialValue.toString(),
          onChanged: (value) {
            setState(() {
              _values[criteria.id] = value;
            });
          },
        );
      case EntitlementCriteriaType.checkbox:
        // Initialize checkbox value to false if not already set
        bool initialValue = getCheckboxValue(criteriaValue);
        return checkBoxField(criteria, initialValue, logger, textTheme, colorScheme, lang);

      case EntitlementCriteriaType.float:
        double initialValue = getFloatValue(criteriaValue);

        return personTextFormField(
          context,
          '',
          inputFieldWidth,
          initialValue: currencyFormatter.formatInitialValue(initialValue),
          onChanged: (value) {
            _values[criteria.id] = parseCurrencyStringToString(value) ?? '';
          },
          validator: (value) => validateCurrency(value, lang),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );

      case EntitlementCriteriaType.currency:
        double initialValue = getCurrencyValue(criteriaValue);

        return personTextFormField(
          context,
          '€',
          inputFieldWidth,
          initialValue: currencyFormatter.formatInitialValue(initialValue),
          onChanged: (value) {
            _values[criteria.id] = parseCurrencyStringToString(value) ?? '0.0';
          },
          validator: (value) => validateCurrency(value, lang),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
        );

      case EntitlementCriteriaType.integer:
        int initialValue = getIntegerValue(criteriaValue);

        double iconSize = 20;
        return integerField(criteria, initialValue, textTheme, iconSize);
      case EntitlementCriteriaType.options:
        List<EntitlementCriteriaOption>? options = criteria.options;

        // can be null, when options are fetched from API
        if (options != null) {
          return optionsField(criteria, criteriaValue, options, textTheme, colorScheme, lang);
        } else {
          return Text(lang.no_options_available);
        }
      default:
        return const SizedBox();
    }
  }

  Container integerField(
    EntitlementCriteria criteria,
    int initialValue,
    TextTheme textTheme,
    double iconSize,
  ) {
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
                initialValue.toString(),
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
                      int newValue = initialValue + 1;
                      setState(() {
                        _values[criteria.id] = newValue.toString();
                      });
                    }
                  },
                  hoverColor: Colors.grey,
                  child: Icon(Icons.arrow_upward, size: iconSize),
                ),
                InkWell(
                  onTap: () {
                    if (_values[criteria.id] != null && initialValue > 1) {
                      int newValue = initialValue - 1;
                      setState(() {
                        _values[criteria.id] = newValue.toString();
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

  FormField<String> optionsField(
    EntitlementCriteria criteria,
    String? initialValue,
    List<EntitlementCriteriaOption> options,
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations lang,
  ) {
    // If initial value is not a label of criteria options, then return null - if not null, then error would be thrown
    // If initial value is null (because was not found in criteria.options, then dropdown field is not filled out and
    // user has opportunity to select an existing option
    String? fieldValue = isLabelInOptions(criteria.options, initialValue) ? initialValue : null;

    return FormField<String>(
      initialValue: fieldValue,
      builder: (FormFieldState<String> state) {
        return Column(
          children: [
            customInputContainer(
              width: inputFieldWidth,
              child: DropdownButton<String>(
                value: fieldValue,
                onChanged: (String? newValue) {
                  setState(() {
                    _values[criteria.id] = newValue ?? '';
                  });
                  state.didChange(_values[criteria.id]);
                },
                items: options.map<DropdownMenuItem<String>>((EntitlementCriteriaOption value) {
                  return DropdownMenuItem<String>(
                    value: value.label,
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
    EntitlementCriteria criteria,
    bool initialValue,
    Logger logger,
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations lang,
  ) {
    bool boolValue = _values[criteria.id] == 'true';
    return FormField<bool>(
      initialValue: initialValue,
      builder: (FormFieldState<bool> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Checkbox(
                value: boolValue,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _values[criteria.id] = value ? 'true' : 'false';
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

  void initializeCriteriaValues(List<EntitlementCriteria> selectedCriterias) {
    for (var criteria in selectedCriterias) {
      if (criteria.type == EntitlementCriteriaType.text) {
        _values[criteria.id] = criteria.initialValue;
      } else if (criteria.type == EntitlementCriteriaType.checkbox) {
        _values[criteria.id] = criteria.initialValue;
      } else if (criteria.type == EntitlementCriteriaType.float) {
        _values[criteria.id] = criteria.initialValue;
      } else if (criteria.type == EntitlementCriteriaType.currency) {
        _values[criteria.id] = criteria.initialValue;
      } else if (criteria.type == EntitlementCriteriaType.integer) {
        _values[criteria.id] = criteria.initialValue;
      } else if (criteria.type == EntitlementCriteriaType.options) {
        _values[criteria.id] = criteria.initialValue;
      }
    }
  }

  // update criteria values from entitlement
  void updateCriteriaValues(Entitlement entitlement) {
    _values = {};
    for (var value in entitlement.values) {
      _values[value.criteriaId] = value.value;
    }
  }
}

bool isLabelInOptions(List<EntitlementCriteriaOption>? options, String? value) {
  if (options != null && value != null) {
    return options.any((option) => option.label == value);
  } else {
    return false;
  }
}
