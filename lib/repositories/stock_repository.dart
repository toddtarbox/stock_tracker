import 'dart:async';

import 'package:meta/meta.dart';

import 'package:stocktracker/repositories/stock_api_client.dart';
import 'package:stocktracker/models/models.dart';

class StockRepository {
  final StockApiClient stockApiClient;

  StockRepository({@required this.stockApiClient})
      : assert(stockApiClient != null);

  Future<StockQuote> getStockQuote(String symbol) async {
    return stockApiClient.fetchStock(symbol);
  }

  Future<StockHistoric> getStockHistoric(String symbol) async {
    return stockApiClient.fetchStockHistoric(symbol);
  }

  Future<StockNews> getStockNews(String symbol) async {
    return stockApiClient.fetchStockNews(symbol);
  }
}
