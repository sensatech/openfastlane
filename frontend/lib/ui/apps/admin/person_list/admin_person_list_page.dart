import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/apps/admin/person/person_model.dart';
import 'package:frontend/ui/apps/admin/admin_values.dart';
import 'package:frontend/ui/apps/admin/commons/admin_content.dart';
import 'package:frontend/ui/apps/admin/person_list/admin_person_list_view_model.dart';
import 'package:frontend/ui/commons/buttons.dart';
import 'package:frontend/ui/commons/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/ofl_scaffold.dart';
import 'package:frontend/ui/values/spacer.dart';

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
    return OflScaffold(
        content: AdminContent(
      width: largeContentWidth,
      breadcrumbs: breadcrumbs,
      customButton: oflButton(
        'neue Person anlegen',
        () {},
      ),
      child: personListContent(context),
    ));
  }

  BreadcrumbsRow get breadcrumbs => BreadcrumbsRow(
        breadcrumbs: [
          OflBreadcrumb('Person List', null),
        ],
      );

  Widget personListContent(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      personListHeaderRow(colorScheme),
      BlocBuilder<AdminPersonListViewModel, AdminPersonListState>(
        builder: (context, state) {
          if (state is AdminPersonListLoading) {
            return const CircularProgressIndicator();
          } else if (state is AdminPersonListLoaded) {
            Person onePerson = state.persons.first;

            return Table(
              children: [
                tableHeaderRow(),
                TableRow(
                  children: [
                    TableCell(
                        child: Row(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.remove_red_eye)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.edit))
                      ],
                    )),
                    TableCell(child: Text(onePerson.firstName)),
                    TableCell(child: Text(onePerson.lastName)),
                    TableCell(child: Text(onePerson.birthdate.toString())),
                    //TODO: add method to format address and also checking whether there is a stair number
                    TableCell(child: Text('${onePerson.street} ${onePerson.streetNumber}, ')),
                    TableCell(child: Text(onePerson.zip)),
                    //TODO: add also this to view model
                    TableCell(
                        child:
                            TextButton(onPressed: () {}, child: Text('Letzter Bezug: 01.01.2021'))),
                  ],
                )
              ],
            );
          } else {
            return const Center(child: Text('Error'));
          }
        },
      ),
    ]);
  }

  TableRow tableHeaderRow() {
    return TableRow(
      children: [
        TableCell(child: Checkbox(value: false, onChanged: (value) {})),
        const TableCell(child: Text('Vorname')),
        const TableCell(child: Text('Nachname')),
        const TableCell(child: Text('Geburtstag')),
        const TableCell(child: Text('Adresse')),
        const TableCell(child: Text('PLZ')),
        const TableCell(child: Text('Lebensmittelausgabe')),
      ],
    );
  }

  Row personListHeaderRow(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [searchTextField(colorScheme), exportButton(colorScheme)],
    );
  }

  Padding exportButton(ColorScheme colorScheme) {
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
                'Datenexportieren',
                style: TextStyle(
                    color: colorScheme.outline,
                    decoration: TextDecoration.underline,
                    decorationColor: colorScheme.outline),
              )
            ],
          )),
    );
  }

  Padding searchTextField(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(mediumSpace),
      child: SizedBox(
        width: 500,
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Nach Person suchen (z.B Name, Adresse)',
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
