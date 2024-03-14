import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/inupt_container.dart';
import 'package:frontend/ui/admin/entitlements/CriteriaForm.dart';
import 'package:frontend/ui/admin/entitlements/commons.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class EditEntitlementContent extends StatefulWidget {
  const EditEntitlementContent({super.key, required this.personId, required this.entitlementCauses});

  final String personId;
  final List<EntitlementCause> entitlementCauses;

  @override
  State<EditEntitlementContent> createState() => _EditEntitlementContentState();
}

class _EditEntitlementContentState extends State<EditEntitlementContent> {
  late EntitlementCause? _selectedCause;
  List<EntitlementCause> _causes = [];

  @override
  void initState() {
    super.initState();
    _causes = widget.entitlementCauses;
    _selectedCause = null;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: smallContentWidth,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Ansuchgrund', style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),
          mediumVerticalSpacer(),
          if (_causes.isNotEmpty)
            criteriaSelectionRow(context, 'Ansuchgrund auswählen:',
                field: customInputContainer(
                  width: inputFieldWidth,
                  child: DropdownButton<EntitlementCause>(
                    value: _selectedCause,
                    hint: Padding(
                      padding: EdgeInsets.all(smallSpace),
                      child: Text('wähle einen Ansuchgrund', style: textTheme.bodyMedium!.copyWith(color: Colors.grey)),
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
                            padding: EdgeInsets.all(smallSpace), child: Text(cause.id, style: textTheme.bodyMedium)),
                      );
                    }).toList(),
                    isExpanded: true,
                    // Makes the dropdown button expand to fill the container
                    underline: const SizedBox(), // removes default underline
                  ),
                ))
          else
            const Text('Error: no causes'),
          largeVerticalSpacer(),
          if (_selectedCause != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Anspruchskriterien', style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
            ),
            mediumVerticalSpacer(),
            CriteriaForm(
              selectedCause: _selectedCause!,
              causes: _causes,
            ),
          ],
          largeVerticalSpacer(),
        ],
      ),
    );
  }
}
