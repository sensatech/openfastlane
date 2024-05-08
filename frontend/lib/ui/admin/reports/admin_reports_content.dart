import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/admin/reports/admin_reports_vm.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';

class AdminReportsContent extends StatefulWidget {
  final AdminReportsViewModel adminReportsViewModel;

  const AdminReportsContent({super.key, required this.adminReportsViewModel});

  @override
  State<AdminReportsContent> createState() => _AdminReportsContentState();
}

class _AdminReportsContentState extends State<AdminReportsContent> {
  late TextEditingController fromController;
  late TextEditingController toController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fromController = TextEditingController();
    toController = TextEditingController();
  }

  Future<void> clickDownload() async {
    setState(() {
      isLoading = true;
    });
    await widget.adminReportsViewModel.prepareReportDownload(
      from: fromController.text,
      to: toController.text,
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return personListContent(context, widget.adminReportsViewModel);
  }

  Widget personListContent(BuildContext context, AdminReportsViewModel viewModel) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          searchTextField(context, fromController, '${lang.from}:'),
          searchTextField(context, toController, '${lang.to}:'),
          OflButton(lang.download, clickDownload, icon: const Icon(Icons.download))
        ],
      ),
      if (isLoading) const Center(child: Padding(padding: EdgeInsets.all(80), child: CircularProgressIndicator()))
    ]);
  }

  Padding searchTextField(BuildContext context, TextEditingController controller, String label) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: SizedBox(
        width: 500,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_month),
            hintText: label,
            hintStyle: const TextStyle(fontSize: 16),
            filled: true,
            fillColor: colorScheme.primaryContainer,
          ),
        ),
      ),
    );
  }
}
