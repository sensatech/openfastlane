import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/input_container.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/commons.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/criteria_form.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class CreateOrEditEntitlementContent extends StatefulWidget {
  const CreateOrEditEntitlementContent(
      {super.key,
      required this.entitlementCauses,
      required this.person,
      required this.createOrEditEntitlement,
      this.entitlement});

  final List<EntitlementCause> entitlementCauses;
  final Person person;
  final Function(String personId, String entitlementCauseId, List<EntitlementValue> values) createOrEditEntitlement;
  final Entitlement? entitlement;

  @override
  State<CreateOrEditEntitlementContent> createState() => _CreateOrEditEntitlementContentState();
}

class _CreateOrEditEntitlementContentState extends State<CreateOrEditEntitlementContent> {
  late EntitlementCause? _selectedCause;
  List<EntitlementCause> _causes = [];

  @override
  void initState() {
    super.initState();
    _causes = widget.entitlementCauses;
    _selectedCause = null;
    //FIXME: fix this!!
    if (widget.entitlement != null) {
      _selectedCause =
          widget.entitlementCauses.where((element) => element.id == widget.entitlement!.entitlementCauseId).first;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;

    return SizedBox(
      width: smallContentWidth,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(lang.entitlement_cause, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),
          mediumVerticalSpacer(),
          if (_causes.isNotEmpty)
            criteriaSelectionRow(context, lang.selection_entitlement_cause,
                field: customInputContainer(
                  width: inputFieldWidth,
                  child: DropdownButton<EntitlementCause>(
                    value: _selectedCause,
                    hint: Padding(
                      padding: EdgeInsets.all(smallPadding),
                      child: Text(lang.select_an_entitlement_cause,
                          style: textTheme.bodyMedium!.copyWith(color: Colors.grey)),
                    ),
                    onChanged: (EntitlementCause? cause) {
                      if (cause != null) {
                        setState(() {
                          _selectedCause = cause;
                        });
                      }
                    },
                    items: _causes.map<DropdownMenuItem<EntitlementCause>>((EntitlementCause cause) {
                      return DropdownMenuItem<EntitlementCause>(
                        value: cause,
                        child: Padding(
                            padding: EdgeInsets.all(smallPadding),
                            child: Text(cause.name ?? 'name Unbekannt', style: textTheme.bodyMedium)),
                      );
                    }).toList(),
                    isExpanded: true,
                    // Makes the dropdown button expand to fill the container
                    underline: const SizedBox(), // removes default underline
                  ),
                ))
          else
            Text(lang.no_entitlement_causes),
          largeVerticalSpacer(),
          if (_selectedCause != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(lang.entitlement_criterias,
                  style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
            ),
            mediumVerticalSpacer(),
            CriteriaForm(
              person: widget.person,
              selectedCause: _selectedCause!,
              causes: _causes,
              entitlement: widget.entitlement,
              createEntitlement: widget.createOrEditEntitlement,
            ),
          ],
          largeVerticalSpacer(),
        ],
      ),
    );
  }
}
