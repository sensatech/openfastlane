import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/persons/person_model.dart';
import 'package:frontend/setup/setup_container.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/person_list/admin_person_list_view_model.dart';
import 'package:frontend/ui/commons/values/address_helper.dart';
import 'package:frontend/ui/commons/values/date_helper.dart';
import 'package:frontend/ui/commons/values/spacer.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class AdminPersonListPage extends StatefulWidget {
  const AdminPersonListPage({super.key});

  static const String routeName = 'admin-person-list';
  static const String path = 'admin_person_list';

  @override
  State<AdminPersonListPage> createState() => _AdminPersonListPageState();
}

class _AdminPersonListPageState extends State<AdminPersonListPage> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context)!;
    BreadcrumbsRow breadcrumbs = getBreadcrumbs(lang);

    return OflScaffold(
        content: AdminContent(
      width: largeContentWidth,
      breadcrumbs: breadcrumbs,
      customButton: oflButton(
        context,
        lang.create_new_person,
        () {},
        icon: Icon(Icons.add, color: theme.colorScheme.onSecondary),
      ),
      child: personListContent(context),
    ));
  }

  BreadcrumbsRow getBreadcrumbs(AppLocalizations lang) {
    return BreadcrumbsRow(
      breadcrumbs: [
        OflBreadcrumb(lang.persons_view, null),
      ],
    );
  }

  Widget personListContent(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    AdminPersonListViewModel viewModel = sl<AdminPersonListViewModel>();
    viewModel.loadAllPersons();

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      personListHeaderRow(colorScheme),
      BlocBuilder<AdminPersonListViewModel, AdminPersonListState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is AdminPersonListLoading) {
            return const CircularProgressIndicator();
          } else if (state is AdminPersonListLoaded) {
            return Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(3),
                4: FlexColumnWidth(5),
                5: FlexColumnWidth(2),
                6: FlexColumnWidth(5),
              },
              children: [
                tableHeaderRow(context),
                ...state.persons.map((person) => customTableRow(context, person))
              ],
            );
          } else {
            return Center(child: Text(lang.an_error_occured));
          }
        },
      ),
    ]);
  }

  TableRow customTableRow(BuildContext context, Person person) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return TableRow(
      children: [
        customTableCell(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.remove_red_eye)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit))
          ],
        )),
        customTableCell(child: Text(person.firstName)),
        customTableCell(child: Text(person.lastName)),
        customTableCell(child: Text(toDateOfBirthString(person.birthDate))),
        customTableCell(child: Text(getHomeAddressString(person.address))),
        customTableCell(child: Text(person.address.postalCode)),
        customTableCell(
            child: TextButton(
                onPressed: () {},
                //TODO: change, when API is available
                child: Text('Letzter Bezug: 01.01.2021',
                    style: TextStyle(
                        color: colorScheme.secondary, decoration: TextDecoration.underline)))),
      ],
    );
  }

  Widget customTableCell({required Widget child}) {
    return TableCell(
      child: SizedBox(
        height: 50,
        child: Align(
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }

  TableRow tableHeaderRow(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    return TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      children: [
        customTableCell(child: Checkbox(value: false, onChanged: (value) {})),
        customTableCell(child: headerText(lang.firstname)),
        customTableCell(child: headerText(lang.lastname)),
        customTableCell(child: headerText(lang.birthdate)),
        customTableCell(child: headerText(lang.address)),
        customTableCell(child: headerText(lang.zip)),
        customTableCell(child: headerText(lang.food_distribution)),
      ],
    );
  }

  Text headerText(String label) => Text(label, style: const TextStyle(fontWeight: FontWeight.bold));

  Row personListHeaderRow(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [searchTextField(context), exportButton(context)],
    );
  }

  Padding exportButton(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(mediumSpace),
      child: TextButton(
          onPressed: () {},
          child: Row(
            children: [
              Icon(
                Icons.cloud_download_outlined,
                color: colorScheme.outline,
              ),
              smallHorizontalSpacer(),
              Text(
                lang.export_data,
                style: TextStyle(
                    color: colorScheme.outline,
                    decoration: TextDecoration.underline,
                    decorationColor: colorScheme.outline),
              )
            ],
          )),
    );
  }

  Padding searchTextField(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(mediumSpace),
      child: SizedBox(
        width: 500,
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: lang.export_data,
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
        ),
      ),
    );
  }
}
