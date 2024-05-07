import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class PersonSearchTextField extends StatelessWidget {
  const PersonSearchTextField({super.key, required this.controller, required this.updateSearchInput});

  final TextEditingController controller;
  final Function(String) updateSearchInput;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: SizedBox(
        width: 500,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: lang.search_for_person,
            hintStyle: const TextStyle(fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            filled: true,
            contentPadding: const EdgeInsets.all(16),
            fillColor: colorScheme.primaryContainer,
          ),
          onChanged: (value) {
            updateSearchInput(value);
          },
        ),
      ),
    );
  }
}
