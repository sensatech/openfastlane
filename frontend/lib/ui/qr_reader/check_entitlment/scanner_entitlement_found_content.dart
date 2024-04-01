import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/person_entitlement_status.dart';

import 'person_entitlement_overview.dart';

typedef OnPersonClicked = Future<void> Function();
typedef OnConsumeClicked = Future<void> Function();

class ScannerEntitlementLoadedPage extends StatefulWidget {
  final Entitlement entitlement;
  final bool readOnly;
  final OnPersonClicked onPersonClicked;
  final OnConsumeClicked? onConsumeClicked;

  const ScannerEntitlementLoadedPage({
    super.key,
    required this.entitlement,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: Colors.red, width: border)),
      ),
      child: Column(children: [
        _title(lang),
        PersonEntitlementOverview(entitlement: widget.entitlement, onPersonClicked: widget.onPersonClicked),
        PersonEntitlementStatus(entitlement: widget.entitlement),
        if (showConsumeButton) consumeButton(),
        _consumptionHistory(['Bezug 1', 'Bezug 2'])
      ]),
    );
  }

  Widget consumeButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
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
            : Text('Bezug eintragen'),
      ),
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

  Widget _consumptionHistory(List<String> list) {
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

  Widget _consumptionHistoryItem(String e) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('✓'),
        Text('12.12.2020'),
      ],
    );
  }
}
