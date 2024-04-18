import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility_type.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
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
    AppLocalizations lang = AppLocalizations.of(context)!;

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
            Entitlement entitlement = state.entitlement;

            String lastConsumption = getFormattedDateAsString(context, consumptionPossibility.lastConsumptionAt) ??
                lang.no_consumption_executed;
            ConsumptionPossibilityType status = consumptionPossibility.status;
            DateTime? expiresAt = entitlement.expiresAt;

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
                        child: centeredHeader(context, lang.last_consumption_on),
                      ),
                      TableCell(
                        child: centeredHeader(context, lang.consumption_eligibility),
                      ),
                      TableCell(
                        child: centeredHeader(context, lang.expires_at),
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
                        child: centeredText(context, getFormattedDateAsString(context, expiresAt) ?? 'keine Angabe'),
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
