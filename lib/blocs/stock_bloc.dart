import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/blocs/blocs.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository stockRepository;

  StockBloc({@required this.stockRepository}) : assert(stockRepository != null);

  @override
  StockState get initialState => StockEmpty();

  @override
  Stream<StockState> mapEventToState(StockEvent event) async* {
    if (event is ClearStock) {
      yield StockEmpty();
    }

    if (event is FetchStock) {
      yield StockLoading();
      try {
        final Future<StockQuote> stockFuture =
            stockRepository.getStockQuote(event.exchange, event.symbol);
        final Future<StockIntraDay> stockIntraDayFuture =
            stockRepository.getStockIntraDay(event.symbol);
        final Future<StockHistoric> stockHistoricFuture =
            stockRepository.getStockHistoric(event.symbol, event.period);
        final Future<StockNews> stockNewsFuture =
            stockRepository.getStockNews(event.symbol);

        StockQuote stockQuote = await Future.wait([
          stockFuture,
          stockIntraDayFuture,
          stockHistoricFuture,
          stockNewsFuture
        ]).then((List responses) {
          StockQuote stockQuote = responses[0];
          stockQuote.stockIntraDay = responses[1];
          stockQuote.stockHistoric = responses[2];
          stockQuote.stockNews = responses[3];
          return stockQuote;
        });

        yield StockLoaded(stockQuote: stockQuote);
      } catch (error) {
        yield StockError(error: error.toString());
      }
    }

    if (event is RefreshStock) {
      yield StockLoading();
      try {
        // Re-fetch just the quote and the intraday
        final Future<StockQuote> stockFuture =
            stockRepository.getStockQuote(event.exchange, event.symbol);
        final Future<StockIntraDay> stockIntraDayFuture =
            stockRepository.getStockIntraDay(event.symbol);

        StockQuote stockQuote =
            await Future.wait([stockFuture, stockIntraDayFuture])
                .then((List responses) {
          StockQuote stockQuote = responses[0];
          stockQuote.stockIntraDay = responses[1];
          return stockQuote;
        });

        yield StockLoaded(stockQuote: stockQuote);
      } catch (error) {
        yield StockError(error: error.toString());
      }
    }

    if (event is RefreshHistoric) {
      yield HistoricReloading(stockQuote: event.stockQuote);
      try {
        // Re-fetch just the historic date for the given period
        final StockHistoric stockHistoric = await stockRepository
            .getStockHistoric(event.stockQuote.symbol, event.period);

        StockQuote stockQuote = event.stockQuote;
        stockQuote.stockHistoric = stockHistoric;

        yield HistoricReloaded(stockQuote: stockQuote);
      } catch (error) {
        yield StockError(error: error.toString());
      }
    }
  }
}
