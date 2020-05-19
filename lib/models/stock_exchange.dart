import 'dart:convert';

import 'package:equatable/equatable.dart';

class StockExchange extends Equatable {
  final String exchange;
  final String region;
  final String description;
  final String mic;
  final String exchangeSuffix;

  StockExchange(
      {this.exchange,
      this.region,
      this.description,
      this.mic,
      this.exchangeSuffix});

  @override
  List<Object> get props =>
      [exchange, region, description, mic, exchangeSuffix];

  String get displayName => '$description ($exchange)';

  @override
  String toString() {
    return displayName;
  }

  Map<String, dynamic> toJson() => {
        'exchange': exchange,
        'region': region,
        'description': description,
        'mic': mic,
        'exchangeSuffix': exchangeSuffix,
      };

  static StockExchange fromPrefsString(String prefsString) {
    dynamic prefsJSON = jsonDecode(prefsString);

    StockExchange stockExchange = StockExchange(
        exchange: prefsJSON['exchange'],
        region: prefsJSON['region'],
        description: prefsJSON['description'],
        mic: prefsJSON['mic'],
        exchangeSuffix: prefsJSON['exchangeSuffix']);

    return stockExchange;
  }

  static StockExchange fromIEXCloudJson(dynamic json) {
    final exchange = json['exchange'];
    final region = json['region'];
    final description = json['description'];
    final mic = json['mic'];
    final exchangeSuffix = json['exchangeSuffix'];

    StockExchange stockExchange = StockExchange(
        exchange: exchange,
        region: region,
        description: description,
        mic: mic,
        exchangeSuffix: exchangeSuffix);

    return stockExchange;
  }

  static List<StockExchange> listFromIEXCloudJson(dynamic json) {
    List<StockExchange> exchanges = json
        .map<StockExchange>((exchangeJson) => fromIEXCloudJson(exchangeJson))
        .toList();

    exchanges.sort((StockExchange a, StockExchange b) =>
        a.description.compareTo(b.description));

    return exchanges;
  }
}
