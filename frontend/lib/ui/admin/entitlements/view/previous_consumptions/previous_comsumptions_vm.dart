import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';

class PreviousConsumptionsViewModel extends Cubit<PreviousConsumptionsState> {
  PreviousConsumptionsViewModel() : super(PreviousConsumptionsInitial());
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
  PreviousConsumptionsLoaded(this.consumptions);

  final List<Consumption> consumptions;

  @override
  List<Object> get props => [consumptions];
}

class PreviousConsumptionsError extends PreviousConsumptionsState {
  PreviousConsumptionsError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
