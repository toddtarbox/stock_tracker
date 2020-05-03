import 'package:equatable/equatable.dart';

class StockMarket extends Equatable {
  final String name;
  final String key;

  StockMarket({this.name, this.key}) : assert(name != null && key != null);

  @override
  List<Object> get props => [name, key];
}
