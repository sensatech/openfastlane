import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/ui/commons/values/typography.dart';

class PersonEntitlementStatus extends StatelessWidget {
  final ConsumptionPossibility consumptionPossibility;

  const PersonEntitlementStatus({super.key, required this.consumptionPossibility});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Bezugstatus', style: fontWhiteBold),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Bezugstatus möglich: $consumptionPossibility', style: fontWhiteBold),
          )
        ],
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
