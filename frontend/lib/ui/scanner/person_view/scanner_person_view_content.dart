import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/scanner/person_view/consumption_history_table.dart';
import 'package:frontend/ui/scanner/person_view/person_detail_table.dart';

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
  bool _showComment = false;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;
    final person = widget.person;
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: Colors.red, width: smallPadding)),
      ),
      child: SingleChildScrollView(
        child: Column(children: [
          _title(person.name),
          PersonDetailTable(person: person),
          Column(
            children: [
              showCommentButton(),
              commentField(person.comment),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: mediumPadding),
            child: const Divider(),
          ),
          if (widget.consumptions != null) ...[
            Text('${lang.previous_consumptions}:', style: textTheme.headlineSmall),
            ConsumptionHistoryTable(items: ConsumptionHistoryItem.fromList(widget.consumptions ?? []))
          ] else
            const CircularProgressIndicator(),
        ]),
      ),
    );
  }

  Widget commentField(String comment) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    return AnimatedSize(
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: SizedBox(
        height: _showComment ? null : 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            (comment.isNotEmpty) ? comment : lang.no_comment_entered,
            style: textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  Widget showCommentButton() {
    AppLocalizations lang = AppLocalizations.of(context)!;
    return OflButton(
      _showComment ? lang.hide_comment : lang.show_comment,
      () {
        setState(() {
          _showComment = !_showComment;
        });
      },
      color: _showComment ? Colors.black : Colors.white,
      textColor: _showComment ? Colors.white : Colors.black,
      borderColor: Colors.black,
    );
  }

  Widget _title(String text) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.all(smallPadding),
      child: Text(text, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
