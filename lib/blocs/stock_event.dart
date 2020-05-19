import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:stocktracker/models/models.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();
}

class ClearStock extends StockEvent {
  @override
  List<Object> get props => [];
}

class FetchStock extends StockEvent {
  final String exchange;
  final String symbol;
  final String period;

  const FetchStock(
      {@required this.symbol, @required this.exchange, @required this.period})
      : assert(symbol != null && exchange != null && period != null);

  @override
  List<Object> get props => [exchange, symbol, period];
}

class RefreshStock extends StockEvent {
  final String exchange;
  final String symbol;
  final String period;

  const RefreshStock(
      {@required this.symbol, @required this.exchange, @required this.period})
      : assert(symbol != null && exchange != null && period != null);

  @override
  List<Object> get props => [exchange, symbol, period];
}

class RefreshHistoric extends StockEvent {
  final StockQuote stockQuote;
  final String period;

  const RefreshHistoric({@required this.stockQuote, @required this.period})
      : assert(stockQuote != null && period != null);

  @override
  List<Object> get props => [stockQuote, period];
}
