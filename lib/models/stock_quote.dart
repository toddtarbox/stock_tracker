import 'package:equatable/equatable.dart';
import 'package:stocktracker/models/models.dart';

class StockQuote extends Equatable {
  final String companyName;
  final String symbol;

  final double open;
  final double high;
  final double low;
  final double fiftyTwoWeekHigh;
  final double fiftyTwoWeekLow;
  final double previousClose;

  final double latestPrice;
  final int latestVolume;
  final int averageVolume;
  final int marketCap;
  final double peRatio;

  StockIntraDay stockIntraDay;
  StockHistoric stockHistoric;
  StockNews stockNews;

  StockQuote(
      {this.companyName,
      this.symbol,
      this.open,
      this.high,
      this.low,
      this.fiftyTwoWeekHigh,
      this.fiftyTwoWeekLow,
      this.previousClose,
      this.latestPrice,
      this.latestVolume,
      this.averageVolume,
      this.marketCap,
      this.peRatio});

  @override
  List<Object> get props => [companyName, symbol];

  String get displayName {
    if (companyName != null && companyName.isNotEmpty) {
      return '$companyName ($symbol)';
    } else {
      return symbol;
    }
  }

  bool isPositiveChange() {
    double change = latestPrice - previousClose;
    return change >= 0;
  }

  String get getChangeText {
    if (previousClose == 0.0) {
      return '$latestPrice';
    } else {
      double change = latestPrice - previousClose;
      return '$latestPrice (' +
          change.toStringAsFixed(change.truncateToDouble() == change ? 0 : 2) +
          ')';
    }
  }

  static StockQuote fromIEXCloudJson(dynamic json) {
    final companyName = json['companyName'];
    final symbol = json['symbol'];

    dynamic open = json['open'];
    dynamic high = json['high'];
    dynamic low = json['low'];
    dynamic fiftyTwoWeekHigh = json['week52High'];
    dynamic fiftyTwoWeekLow = json['week52Low'];

    dynamic latestVolume = json['volume'];
    dynamic averageVolume = json['avgTotalVolume'];
    dynamic marketCap = json['marketCap'];
    dynamic peRatio = json['peRatio'];

    dynamic previousClose = json['previousClose'];
    if (previousClose == null) {
      previousClose = 0.0;
    } else if (previousClose is String) {
      previousClose = previousClose.toDouble();
    } else {
      previousClose = previousClose.toDouble();
    }

    dynamic latestPrice = json['latestPrice'];
    if (latestPrice == null) {
      latestPrice = 0.0;
    } else if (latestPrice is String) {
      latestPrice = double.parse(latestPrice);
    } else {
      latestPrice = latestPrice.toDouble();
    }

    StockQuote stockQuote = StockQuote(
        companyName: companyName,
        symbol: symbol,
        open: open,
        high: high,
        low: low,
        fiftyTwoWeekHigh: fiftyTwoWeekHigh,
        fiftyTwoWeekLow: fiftyTwoWeekLow,
        latestVolume: latestVolume,
        averageVolume: averageVolume,
        marketCap: marketCap,
        peRatio: peRatio,
        previousClose: previousClose,
        latestPrice: latestPrice);

    return stockQuote;
  }
}
