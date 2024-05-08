import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class PersonEntitlementOverview extends StatelessWidget {
  final Person person;

  final EntitlementCause? entitlementCause;

  const PersonEntitlementOverview({
    super.key,
    required this.person,
    required this.entitlementCause,
  });

  @override
  Widget build(BuildContext context) {
    String? dateOfBirth;
    dateOfBirth = formatDateLong(context, person.dateOfBirth);
    NavigationService navigationService = sl<NavigationService>();

    return Padding(
        padding: EdgeInsets.symmetric(vertical: mediumPadding, horizontal: largeSpace),
        child: Center(
          child: Table(
            children: <TableRow>[
              // FIXME i18n
              buildTableRow(context, 'Name', person.name, onClick: () {
                navigationService.pushNamedWithCampaignId(context, ScannerRoutes.scannerPerson.name,
                    pathParameters: {'personId': person.id});
              }),
              rowSpacer(),
              buildTableRow(context, 'Geburtsdatum', dateOfBirth ?? ''),
              rowSpacer(),
              if (entitlementCause?.campaign?.name != null)
                buildTableRow(context, 'Kampagne', entitlementCause!.campaign!.name),
              rowSpacer(),
              buildTableRow(context, 'Ansuchgrund', entitlementCause!.name),
            ],
          ),
        ));
  }

  TableRow buildTableRow(
    BuildContext context,
    String label,
    String value, {
    VoidCallback? onClick,
  }) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return TableRow(
      children: <Widget>[
        Text(label, style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
        if (onClick != null)
          InkWell(
            onTap: onClick,
            child: Text(
              value,
              style: textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.normal,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        else
          tableValue(context, value),
      ],
    );
  }

  Widget tableValue(BuildContext context, String value) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(value, style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.normal));
  }
}
