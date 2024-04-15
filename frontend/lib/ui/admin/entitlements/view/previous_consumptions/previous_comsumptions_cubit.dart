import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';

class PreviousConsumptionsCubit extends Cubit<PreviousConsumptionsState> {
  PreviousConsumptionsCubit(this._entitlementsService) : super(PreviousConsumptionsInitial());

  final EntitlementsService _entitlementsService;

  Future<void> getConsumptions(String entitlementId) async {
    emit(PreviousConsumptionsLoading());
    try {
      ConsumptionPossibility consumptionPossibility = await _entitlementsService.canConsume(entitlementId);
      emit(PreviousConsumptionsLoaded(consumptionPossibility));
    } catch (e) {
      emit(PreviousConsumptionsError(e.toString()));
    }
  }
}

@immutable
abstract class PreviousConsumptionsState extends Equatable {}

class PreviousConsumptionsInitial extends PreviousConsumptionsState {
  @override
  List<Object> get props => [];
}

class PreviousConsumptionsLoading extends PreviousConsumptionsState {
  @override
  List<Object> get props => [];
}

class PreviousConsumptionsLoaded extends PreviousConsumptionsState {
  PreviousConsumptionsLoaded(this.consumptionPossibility);

  final ConsumptionPossibility consumptionPossibility;

  @override
  List<Object> get props => [consumptionPossibility];
}

class PreviousConsumptionsError extends PreviousConsumptionsState {
  PreviousConsumptionsError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
