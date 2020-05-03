import 'package:equatable/equatable.dart';
import 'package:stocktracker/models/models.dart';

class StockQuote extends Equatable {
  final String companyName;
  final String symbol;
  final double previousClose;
  final double latestPrice;

  StockIntraDay stockIntraDay;
  StockHistoric stockHistoric;
  StockNews stockNews;

  StockQuote(
      {this.companyName, this.symbol, this.previousClose, this.latestPrice});

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
        previousClose: previousClose,
        latestPrice: latestPrice);

    return stockQuote;
  }
}
