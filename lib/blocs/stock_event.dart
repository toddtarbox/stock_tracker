import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();
}

class FetchStock extends StockEvent {
  final String symbol;

  const FetchStock({@required this.symbol}) : assert(symbol != null);

  @override
  List<Object> get props => [symbol];
}

class RefreshStock extends StockEvent {
  final String symbol;

  const RefreshStock({@required this.symbol}) : assert(symbol != null);

  @override
  List<Object> get props => [symbol];
}
