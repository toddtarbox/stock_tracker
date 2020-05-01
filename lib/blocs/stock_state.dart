import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:stocktracker/models/models.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object> get props => [];
}

class StockEmpty extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final StockQuote stockQuote;

  const StockLoaded({@required this.stockQuote}) : assert(stockQuote != null);

  @override
  List<Object> get props => [stockQuote];
}

class StockError extends StockState {
  final String error;

  const StockError({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'StockError { error: $error }';
}
