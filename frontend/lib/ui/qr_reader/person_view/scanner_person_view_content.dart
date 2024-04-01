import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/qr_reader/person_view/person_detail_table.dart';

import 'consumption_history_table.dart';

typedef OnPersonClicked = Future<void> Function();
typedef OnConsumeClicked = Future<void> Function();

class ScannerPersonViewContent extends StatefulWidget {
  final Person person;

  const ScannerPersonViewContent({
    super.key,
    required this.person,
  });

  @override
  State<ScannerPersonViewContent> createState() {
    return _ScannerPersonViewContentState();
  }
}

class _ScannerPersonViewContentState extends State<ScannerPersonViewContent> {
  bool showComment = false;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    final person = widget.person;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: Colors.red, width: 4.0)),
      ),
      child: Column(children: [
        _title(widget.person.name),
        PersonDetailTable(person: widget.person),
        Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              showCommentButton(),
              commentField(person.comment),
            ],
          ),
        ),
        ConsumptionHistoryTable(items: [
          ConsumptionHistoryItem('12.12.2020', 'Bezug 1'),
          ConsumptionHistoryItem('12.12.2020', 'Bezug 2'),
        ])
      ]),
    );
  }

  Widget commentField(String comment) {
    return AnimatedSize(
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: Container(
          color: Colors.grey[300],
          height: showComment ? null : 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              comment,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 30,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));
  }

  Widget showCommentButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            showComment = !showComment;
          });
        },
        child: (showComment) ? const Text('Kommentar verbergen') : const Text('Kommentar anzeigen'),
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
