import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility_type.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class PersonEntitlementStatus extends StatelessWidget {
  final ConsumptionPossibility consumptionPossibility;

  const PersonEntitlementStatus({super.key, required this.consumptionPossibility});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ConsumptionPossibilityType status = consumptionPossibility.status;
    String? lastConsumtion = formatDateTimeLong(context, consumptionPossibility.lastConsumptionAt);
    return Container(
      width: double.infinity,
      color: status.toColor(),
      child: Padding(
        padding: EdgeInsets.all(mediumPadding),
        child: Column(
          children: [
            Text(
              'Bezugsstatus:',
              style: textTheme.headlineSmall!.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            mediumVerticalSpacer(),
            Text(
              status.toLocale(context),
              style: textTheme.bodyLarge!.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (status == ConsumptionPossibilityType.consumptionAlreadyDone && lastConsumtion != null)
              Text(
                lastConsumtion,
                style: textTheme.bodyLarge!.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              )
          ],
        ),
      ),
    );
  }

  Widget tableLabel(String s) {
    return Text(s, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget tableValue(String s) {
    return Text(s, style: const TextStyle(fontWeight: FontWeight.normal));
  }
}
