import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart';

import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/models/stock_historic.dart';

class StockApiClient {
  static const IEX_API_KEY = String.fromEnvironment('IEX_API_KEY');
  static const String baseBatchUrl =
      'https://cloud.iexapis.com/stable/stock/%s/batch?&types=quote,intraday-prices&range=3m&token=' + IEX_API_KEY;
  static const String baseHistoricUrl =
      'https://cloud.iexapis.com/stable/stock/%s/chart/3m?token=' + IEX_API_KEY;

  final Client httpClient;

  StockApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null && String.fromEnvironment('IEX_API_KEY') != '');

  Future<StockQuote> fetchStock(String symbol) async {
    final quoteUrl = baseBatchUrl.replaceAll('%s', symbol);
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception('Error getting stock quote for symbol: ' + symbol);
    }

    final quoteJson = jsonDecode(response.body);
    return StockQuote.fromJson(quoteJson);
  }

  Future<StockHistoric> fetchStockHistoric(String symbol) async {
    final quoteUrl = baseHistoricUrl.replaceAll('%s', symbol);
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception(
          'Error getting stock historic prices for symbol: ' + symbol);
    }

    final dayJson = jsonDecode(response.body);
    return StockHistoric.fromJson(dayJson);
  }
}
