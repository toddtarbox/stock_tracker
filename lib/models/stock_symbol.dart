import 'dart:convert';

import 'package:equatable/equatable.dart';

class StockSymbol extends Equatable {
  final String name;
  final String symbol;

  StockSymbol({this.name, this.symbol});

  @override
  List<Object> get props => [name, symbol];

  String get displayName => '$name ($symbol)';

  @override
  String toString() {
    return displayName;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'symbol': symbol,
      };

  static StockSymbol fromPrefsString(String prefsString) {
    dynamic prefsJSON = jsonDecode(prefsString);

    StockSymbol stockSymbol =
        StockSymbol(name: prefsJSON['name'], symbol: prefsJSON['symbol']);

    return stockSymbol;
  }

  static StockSymbol fromIEXCloudJson(dynamic json) {
    final name = json['name'];
    final symbol = json['symbol'];

    StockSymbol stockSymbol = StockSymbol(name: name, symbol: symbol);

    return stockSymbol;
  }

  static List<StockSymbol> listFromIEXCloudJson(dynamic json) {
    List<StockSymbol> symbols = json
        .map<StockSymbol>((symbolJson) => fromIEXCloudJson(symbolJson))
        .toList();

    symbols.sort((StockSymbol a, StockSymbol b) => a.name.compareTo(b.name));

    return symbols;
  }
}
