import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:stocktracker/models/models.dart';

abstract class ExchangeSymbolsState extends Equatable {
  const ExchangeSymbolsState();

  @override
  List<Object> get props => [];
}

class ExchangeSymbolsEmpty extends ExchangeSymbolsState {}

class ExchangeSymbolsLoading extends ExchangeSymbolsState {}

class ExchangeSymbolsLoaded extends ExchangeSymbolsState {
  final List<StockSymbol> symbols;

  const ExchangeSymbolsLoaded({@required this.symbols})
      : assert(symbols != null);

  @override
  List<Object> get props => [symbols];
}

class ExchangeSymbolsError extends ExchangeSymbolsState {
  final String error;

  const ExchangeSymbolsError({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'ExchangeSymbolsError { error: $error }';
}
