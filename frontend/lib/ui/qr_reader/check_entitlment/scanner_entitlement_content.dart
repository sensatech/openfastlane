import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility_type.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/widgets/person_entitlement_overview.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/widgets/person_entitlement_status.dart';
import 'package:frontend/ui/qr_reader/person_view/consumption_history_table.dart';

typedef OnPersonClicked = Future<void> Function();
typedef OnConsumeClicked = Future<void> Function();

class ScannerEntitlementContent extends StatefulWidget {
  final Entitlement entitlement;
  final ConsumptionPossibility? consumptionPossibility;
  final List<Consumption>? consumptions;

  final bool canConsume;
  final OnConsumeClicked? onConsumeClicked;

  const ScannerEntitlementContent({
    super.key,
    required this.entitlement,
    required this.consumptionPossibility,
    required this.consumptions,
    required this.canConsume,
    this.onConsumeClicked,
  });

  @override
  State<ScannerEntitlementContent> createState() {
    return _ScannerEntitlementLoadedState();
  }
}

class _ScannerEntitlementLoadedState extends State<ScannerEntitlementContent> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    final showConsumeButton = widget.canConsume == true && widget.onConsumeClicked != null;
    var border = (showConsumeButton) ? 4.0 : 0.0;
    var possible = widget.consumptionPossibility?.status == ConsumptionPossibilityType.consumptionPossible;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: Colors.red, width: border)),
      ),
      child: Column(children: [
        _title(lang),
        if (widget.entitlement.person != null)
          PersonEntitlementOverview(
            person: widget.entitlement.person!,
            entitlementCause: widget.entitlement.entitlementCause,
          )
        else
          Padding(
            padding: EdgeInsets.all(smallPadding),
            child: const Text('Person nicht gefunden'),
          ),
        if (widget.consumptionPossibility != null)
          PersonEntitlementStatus(consumptionPossibility: widget.consumptionPossibility!)
        else
          const SizedBox(height: 16, child: CircularProgressIndicator()),
        if (showConsumeButton && possible) consumeButton(),
        if (widget.consumptions != null)
          _consumptionHistory(ConsumptionHistoryItem.fromList(widget.consumptions!))
        else
          const SizedBox(height: 16, child: CircularProgressIndicator()),
      ]),
    );
  }

  Widget consumeButton() {
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: OflButton(
        'Bezug eintragen',
        () async {
          {
            setState(() {
              isLoading = true;
            });
            await widget.onConsumeClicked!();
            setState(() {
              isLoading = false;
            });
          }
          ;
        },
      ),
    );
  }

  Widget _title(AppLocalizations lang) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Anspruchsberechtigung für',
        style: textTheme.headlineSmall,
      ),
    );
  }

  Widget _consumptionHistory(List<ConsumptionHistoryItem> list) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Vergangene Bezüge:',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...list.map((e) => _consumptionHistoryItem(e)),
          ],
        ),
      ),
    );
  }

  Widget _consumptionHistoryItem(ConsumptionHistoryItem item) {
    String? date = formatDateTimeLong(context, item.date);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (date != null) ...[const Text('✓ '), Text(date)]
      ],
    );
  }
}
