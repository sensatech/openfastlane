import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility_type.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/entitlements/view/previous_consumptions/previous_comsumptions_cubit.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/text_widgets.dart';

class PreviousConsumptionsTabContent extends StatelessWidget {
  const PreviousConsumptionsTabContent({super.key, required this.entitlementId});

  final String entitlementId;

  @override
  Widget build(BuildContext context) {
    PreviousConsumptionsCubit cubit = sl<PreviousConsumptionsCubit>();
    cubit.getConsumptions(entitlementId);

    return BlocBuilder<PreviousConsumptionsCubit, PreviousConsumptionsState>(
        bloc: cubit,
        builder: (context, state) {
          Widget child = const SizedBox();
          if (state is PreviousConsumptionsError) {
            child = centeredErrorText(context);
          } else if (state is PreviousConsumptionsLoaded) {
            ConsumptionPossibility consumptionPossibility = state.consumptionPossibility;
            String lastConsumption = getFormattedDateAsString(context, consumptionPossibility.lastConsumptionAt) ??
                'keinen Bezug vogenommen';
            ConsumptionPossibilityType status = consumptionPossibility.status;
            //FIXME: not sure where to get this from
            DateTime? validUntil = DateTime.now().add(const Duration(days: 60));

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: smallPadding, vertical: mediumPadding),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: centeredHeader(context, 'letzter Bezug am'),
                      ),
                      TableCell(
                        child: centeredHeader(context, 'Bezugsberechtigung'),
                      ),
                      TableCell(
                        child: centeredHeader(context, 'Gültig bis'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: centeredText(context, lastConsumption),
                      ),
                      TableCell(
                        child: centeredText(context, status.toLocale(context), color: status.toColor()),
                      ),
                      TableCell(
                        child: centeredText(context, getFormattedDateAsString(context, validUntil) ?? 'keine Angabe'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return child;
        });
  }

  Center centeredHeader(BuildContext context, String text) {
    return Center(
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Center centeredText(BuildContext context, String text, {Color? color}) {
    return Center(
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: color)),
    );
  }
}
