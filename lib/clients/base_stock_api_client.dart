import 'package:stocktracker/models/models.dart';

abstract class StockApiClient {
  Future<List<StockExchange>> fetchExchanges();
  Future<List<StockSymbol>> fetchExchangeSymbols(String exchange);
  Future<StockQuote> fetchStock(String exchange, String symbol);
  Future<StockIntraDay> fetchStockIntraDay(String symbol);
  Future<StockHistoric> fetchStockHistoric(String symbol, String period);
  Future<StockNews> fetchStockNews(String symbol);
}
