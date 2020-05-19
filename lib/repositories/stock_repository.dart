import 'dart:async';

import 'package:meta/meta.dart';

import 'package:stocktracker/clients/base_stock_api_client.dart';
import 'package:stocktracker/models/models.dart';

class StockRepository {
  final StockApiClient stockApiClient;

  StockRepository({@required this.stockApiClient})
      : assert(stockApiClient != null);

  Future<List<StockExchange>> getExchanges() async {
    return stockApiClient.fetchExchanges();
  }

  Future<List<StockSymbol>> getExchangeSymbols(String exchange) async {
    return stockApiClient.fetchExchangeSymbols(exchange);
  }

  Future<StockQuote> getStockQuote(String exchange, String symbol) async {
    return stockApiClient.fetchStock(exchange, symbol);
  }

  Future<StockIntraDay> getStockIntraDay(String symbol) async {
    return stockApiClient.fetchStockIntraDay(symbol);
  }

  Future<StockHistoric> getStockHistoric(String symbol, String period) async {
    return stockApiClient.fetchStockHistoric(symbol, period);
  }

  Future<StockNews> getStockNews(String symbol) async {
    return stockApiClient.fetchStockNews(symbol);
  }
}
