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
    if (event is FetchStock) {
      yield StockLoading();
      try {
        final StockQuote stock =
            await stockRepository.getStockQuote(event.exchange, event.symbol);
        final StockIntraDay stockIntraDay =
            await stockRepository.getStockIntraDay(event.symbol);
        final StockHistoric stockHistoric =
            await stockRepository.getStockHistoric(event.symbol);
        final StockNews stockNews =
            await stockRepository.getStockNews(event.symbol);

        stock.stockIntraDay = stockIntraDay;
        stock.stockHistoric = stockHistoric;
        stock.stockNews = stockNews;
        yield StockLoaded(stockQuote: stock);
      } catch (error) {
        yield StockError(error: error.toString());
      }
    }

    if (event is RefreshStock) {
      yield StockLoading();
      try {
        final StockQuote stock =
            await stockRepository.getStockQuote(event.exchange, event.symbol);
        final StockIntraDay stockIntraDay =
            await stockRepository.getStockIntraDay(event.symbol);
        final StockHistoric stockHistoric =
            await stockRepository.getStockHistoric(event.symbol);
        final StockNews stockNews =
            await stockRepository.getStockNews(event.symbol);

        stock.stockIntraDay = stockIntraDay;
        stock.stockHistoric = stockHistoric;
        stock.stockNews = stockNews;
        yield StockLoaded(stockQuote: stock);
      } catch (_) {
        yield state;
      }
    }
  }
}
