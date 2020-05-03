import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class ExchangeSymbolsEvent extends Equatable {
  const ExchangeSymbolsEvent();
}

class ClearExchange extends ExchangeSymbolsEvent {
  @override
  List<Object> get props => [];
}

class FetchExchangeSymbols extends ExchangeSymbolsEvent {
  final String exchange;

  const FetchExchangeSymbols({@required this.exchange})
      : assert(exchange != null);

  @override
  List<Object> get props => [exchange];
}
