import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/admin/reports/admin_reports_vm.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
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
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;

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
      context,
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
          searchTextField(context, fromController, '${lang.from}:', selectDate: () {
            _selectDate(context, _selectedFromDate, fromController);
          }),
          searchTextField(context, toController, '${lang.to}:', selectDate: () {
            _selectDate(context, _selectedToDate, toController);
          }),
          OflButton(lang.download, clickDownload, iconData: Icons.download)
        ],
      ),
      if (isLoading) const Center(child: Padding(padding: EdgeInsets.all(80), child: CircularProgressIndicator()))
    ]);
  }

  Padding searchTextField(BuildContext context, TextEditingController controller, String label,
      {required Function selectDate}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: SizedBox(
        width: 500,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  selectDate.call();
                }),
            hintText: label,
            hintStyle: const TextStyle(fontSize: 16),
            filled: true,
            fillColor: colorScheme.primaryContainer,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime? selectedDate, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2024, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        String? selectedDateStr = formatDateShort(context, selectedDate);
        if (selectedDateStr != null) {
          controller.text = selectedDateStr;
        }
      });
    }
  }
}
