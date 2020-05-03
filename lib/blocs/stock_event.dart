import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

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

  const FetchStock({@required this.symbol, @required this.exchange})
      : assert(symbol != null && exchange != null);

  @override
  List<Object> get props => [exchange, symbol];
}

class RefreshStock extends StockEvent {
  final String exchange;
  final String symbol;

  const RefreshStock({@required this.symbol, @required this.exchange})
      : assert(symbol != null && exchange != null);

  @override
  List<Object> get props => [exchange, symbol];
}
