import 'package:flutter/material.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/person_search_text_field.dart';

class ScannerPersonListContent extends StatefulWidget {
  const ScannerPersonListContent(
      {super.key, this.campaignName, required this.persons, required this.updateSearchInput});

  final String? campaignName;
  final List<Person> persons;
  final Function(String) updateSearchInput;

  @override
  State<ScannerPersonListContent> createState() => _ScannerPersonListContentState();
}

class _ScannerPersonListContentState extends State<ScannerPersonListContent> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mediumVerticalSpacer(),
            if (widget.campaignName != null) ...[
              Text('Kampagne:', style: textTheme.headlineMedium),
              Text(widget.campaignName!, style: textTheme.headlineMedium),
              mediumVerticalSpacer()
            ],
            PersonSearchTextField(searchController: controller, updateSearchInput: widget.updateSearchInput),
            mediumVerticalSpacer(),
            if (widget.persons.isNotEmpty)
              ...widget.persons.map((person) {
                return Padding(
                  padding: EdgeInsets.all(smallPadding),
                  child: Text(person.name),
                );
              })
          ],
        ),
      ),
    );
  }
}
