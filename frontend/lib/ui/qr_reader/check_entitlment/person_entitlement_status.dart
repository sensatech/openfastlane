import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/ui/commons/values/typography.dart';

class PersonEntitlementStatus extends StatelessWidget {
  final Entitlement entitlement;

  const PersonEntitlementStatus({super.key, required this.entitlement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Bezugstatus", style: fontWhiteBold),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Bezugstatus möglich: ${entitlement.personId}", style: fontWhiteBold),
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
