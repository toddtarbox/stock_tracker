import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:stocktracker/models/models.dart';

abstract class ExchangesState extends Equatable {
  const ExchangesState();

  @override
  List<Object> get props => [];
}

class ExchangesEmpty extends ExchangesState {}

class ExchangesLoading extends ExchangesState {}

class ExchangesLoaded extends ExchangesState {
  final List<StockExchange> exchanges;

  const ExchangesLoaded({@required this.exchanges}) : assert(exchanges != null);

  @override
  List<Object> get props => [exchanges];
}

class ExchangesError extends ExchangesState {
  final String error;

  const ExchangesError({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'ExchangesError { error: $error }';
}
