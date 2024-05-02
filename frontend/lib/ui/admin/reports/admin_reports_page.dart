import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/reports/admin_reports_vm.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

import 'package:frontend/ui/admin/reports/admin_reports_content.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  static const String routeName = 'admin-reports';
  static const String path = 'reports';

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    BreadcrumbsRow breadcrumbs = getBreadcrumbs(lang);
    AdminReportsViewModel viewModel = sl<AdminReportsViewModel>();

    return OflScaffold(
        content: AdminContent(
      width: largeContainerWidth,
      breadcrumbs: breadcrumbs,
      showDivider: true,
      customButton: null,
      child: AdminReportsContent(adminReportsViewModel: viewModel),
    ));
  }

  BreadcrumbsRow getBreadcrumbs(AppLocalizations lang) {
    return BreadcrumbsRow(
      breadcrumbs: [
        OflBreadcrumb('Export'),
      ],
    );
  }
}
