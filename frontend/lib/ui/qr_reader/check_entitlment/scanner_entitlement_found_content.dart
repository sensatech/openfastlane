import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility_type.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/person_entitlement_overview.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/person_entitlement_status.dart';
import 'package:frontend/ui/qr_reader/person_view/consumption_history_table.dart';

typedef OnPersonClicked = Future<void> Function();
typedef OnConsumeClicked = Future<void> Function();

class ScannerEntitlementLoadedPage extends StatefulWidget {
  final Entitlement entitlement;
  final ConsumptionPossibility? consumptionPossibility;
  final List<Consumption>? consumptions;

  final bool readOnly;
  final OnPersonClicked onPersonClicked;
  final OnConsumeClicked? onConsumeClicked;

  const ScannerEntitlementLoadedPage({
    super.key,
    required this.entitlement,
    required this.consumptionPossibility,
    required this.consumptions,
    required this.readOnly,
    required this.onPersonClicked,
    this.onConsumeClicked,
  });

  @override
  State<ScannerEntitlementLoadedPage> createState() {
    return _ScannerEntitlementLoadedState();
  }
}

class _ScannerEntitlementLoadedState extends State<ScannerEntitlementLoadedPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    final showConsumeButton = widget.readOnly == false && widget.onConsumeClicked != null;
    var border = (showConsumeButton) ? 4.0 : 0.0;
    var possible = widget.consumptionPossibility?.status == ConsumptionPossibilityType.consumptionPossible;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: Colors.red, width: border)),
      ),
      child: Column(children: [
        _title(lang),
        PersonEntitlementOverview(
          person: widget.entitlement.person,
          entitlementCause: widget.entitlement.entitlementCause,
          onPersonClicked: widget.onPersonClicked,
        ),
        if (widget.consumptionPossibility != null)
          PersonEntitlementStatus(consumptionPossibility: widget.consumptionPossibility!)
        else
          const SizedBox(height: 16, child: CircularProgressIndicator()),
        if (showConsumeButton) consumeButton(possible),
        if (widget.consumptions != null)
          _consumptionHistory(ConsumptionHistoryItem.fromList(widget.consumptions!))
        else
          const SizedBox(height: 16, child: CircularProgressIndicator()),
      ]),
    );
  }

  Widget consumeButton(bool possible) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
          onPressed: !possible
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                  });
                  await widget.onConsumeClicked!();
                  setState(() {
                    isLoading = false;
                  });
                },
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              : Text(possible ? 'Bezug eintragen' : 'Bezug nicht möglich')),
    );
  }

  Widget _title(AppLocalizations lang) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Anspruchberechtigung für:',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _consumptionHistory(List<ConsumptionHistoryItem> list) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Vergangene Bezüge:'),
            const SizedBox(height: 16),
            ...list.map((e) => _consumptionHistoryItem(e)),
          ],
        ),
      ),
    );
  }

  Widget _consumptionHistoryItem(ConsumptionHistoryItem item) {
    var string = item.date.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('✓ '),
        Text(string),
      ],
    );
  }
}
