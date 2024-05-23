import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/person/person_search_util.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class SearchInfo extends StatelessWidget {

  final bool isInitial;
  const SearchInfo({super.key, required this.isInitial});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context)!;

    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (isInitial)
            Text(lang.person_search_initial, style: theme.textTheme.titleMedium)
          else
            Text(lang.person_search_none, style: theme.textTheme.titleMedium),
        ]));
  }
}

class SearchResultInfo extends StatelessWidget {
  final SearchFilter searchFilter;
  final int length;

  const SearchResultInfo(this.searchFilter, this.length, {super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$length ${lang.person_search_x_results}', style: theme.textTheme.titleLarge),
          mediumHorizontalSpacer(),
          if (searchFilter.firstName != null) buildText(context, lang.firstname, searchFilter.firstName!),
          if (searchFilter.lastName != null) buildText(context, lang.lastname, searchFilter.lastName!),
          if (searchFilter.dateOfBirth != null) buildText(context, lang.dateOfBirth, searchFilter.dateOfBirth!),
          if (searchFilter.streetNameNumber != null)
            buildText(context, lang.streetNameNumber, searchFilter.streetNameNumber!),
        ]));
  }

  Row buildText(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(' = ', style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.bodyMedium),
        mediumHorizontalSpacer(),
      ],
    );
  }
}
