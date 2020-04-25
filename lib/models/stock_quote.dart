import 'package:equatable/equatable.dart';
import 'package:stocktracker/models/models.dart';

class StockQuote extends Equatable {
  final String name;
  final String symbol;
  final double openPrice;
  final double latestPrice;

  final StockIntraDay stockIntraDay;
  StockHistoric stockHistoric;

  StockQuote(
      {this.name,
      this.symbol,
      this.openPrice,
      this.latestPrice,
      this.stockIntraDay});

  @override
  List<Object> get props => [name, symbol];

  bool isPositiveChange() {
    double change = latestPrice - openPrice;
    return change >= 0;
  }

  String getChangedText() {
    double change = latestPrice - openPrice;
    return ' (' +
        change.toStringAsFixed(change.truncateToDouble() == change ? 0 : 2) +
        ')';
  }

  static StockQuote fromJson(dynamic json) {
    final quoteJson = json['quote'];
    final intraDayJson = json['intraday-prices'];

    final stockName = quoteJson['companyName'];
    final stockSymbol = quoteJson['symbol'];
    final openPrice = quoteJson['previousClose'];
    final latestPrice = quoteJson['latestPrice'];

    final StockIntraDay stockIntraDay = StockIntraDay.fromJson(intraDayJson);

    StockQuote stockQuote = StockQuote(
        name: stockName,
        symbol: stockSymbol,
        openPrice: openPrice.toDouble(),
        latestPrice: latestPrice.toDouble(),
        stockIntraDay: stockIntraDay);

    return stockQuote;
  }
}
