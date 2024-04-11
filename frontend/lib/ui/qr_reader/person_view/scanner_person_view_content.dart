import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/qr_reader/person_view/consumption_history_table.dart';
import 'package:frontend/ui/qr_reader/person_view/person_detail_table.dart';

typedef OnPersonClicked = Future<void> Function();
typedef OnConsumeClicked = Future<void> Function();

class ScannerPersonViewContent extends StatefulWidget {
  final Person person;
  final List<Consumption>? consumptions;

  const ScannerPersonViewContent({
    super.key,
    required this.person,
    this.consumptions,
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
    final person = widget.person;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: Colors.red, width: 4.0)),
      ),
      child: Column(children: [
        _title(person.name),
        PersonDetailTable(person: person),
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
        if (widget.consumptions != null)
          ConsumptionHistoryTable(items: ConsumptionHistoryItem.fromList(widget.consumptions ?? []))
        else
          const CircularProgressIndicator(),
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
