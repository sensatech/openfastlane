import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility_type.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/scanner/check_entitlement/widgets/person_entitlement_overview.dart';
import 'package:frontend/ui/scanner/check_entitlement/widgets/person_entitlement_status.dart';
import 'package:frontend/ui/scanner/person_view/consumption_history_table.dart';
import 'package:go_router/go_router.dart';

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
    var possible = widget.consumptionPossibility?.status == ConsumptionPossibilityType.consumptionPossible;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: Colors.red, width: smallPadding)),
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
            child: Text(lang.person_not_found),
          ),
        if (widget.consumptionPossibility != null)
          PersonEntitlementStatus(consumptionPossibility: widget.consumptionPossibility!)
        else
          const SizedBox(height: 16, child: CircularProgressIndicator()),
        if (showConsumeButton && possible) consumeButton(),
        if (widget.consumptions != null)
          _consumptionHistory(ConsumptionHistoryItem.fromList(widget.consumptions!), lang)
        else
          const SizedBox(height: 16, child: CircularProgressIndicator()),
      ]),
    );
  }

  Widget consumeButton() {
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: OflButton(
        lang.enter_consumption,
        () async {
          {
            showDialog(context: context, builder: (context) => buildConsumeDialog(lang));
          }
        },
      ),
    );
  }

  Widget _title(AppLocalizations lang) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        lang.entitlement_for,
        style: textTheme.headlineSmall,
      ),
    );
  }

  Widget _consumptionHistory(List<ConsumptionHistoryItem> list, AppLocalizations lang) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${lang.previous_consumptions}:',
              style: textTheme.headlineSmall,
            ),
            mediumVerticalSpacer(),
            ...list.map((e) {
              String? formattedDate = formatDateTimeLong(context, e.date);
              if (formattedDate != null) {
                return _consumptionHistoryItem(formattedDate);
              } else {
                return const SizedBox();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _consumptionHistoryItem(String formattedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [const Text('✓ '), Text(formattedDate)],
    );
  }

  Widget buildConsumeDialog(AppLocalizations lang) {
    return AlertDialog(
      title: Text(lang.enter_consumption),
      content: Text(lang.enter_consumption_question),
      actions: <Widget>[
        OflButton(
          lang.cancel,
          () {
            context.pop();
          },
          color: Colors.transparent,
          textColor: Colors.black,
        ),
        OflButton(
          'Ja',
          () async {
            setState(() {
              isLoading = true;
            });
            await widget.onConsumeClicked!();
            setState(() {
              isLoading = false;
            });
            if (!mounted) return;
            context.pop();
          },
          color: Colors.transparent,
          textColor: Colors.black,
        ),
      ],
    );
  }
}
