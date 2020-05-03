import 'package:equatable/equatable.dart';

abstract class ExchangesEvent extends Equatable {
  const ExchangesEvent();
}

class FetchExchanges extends ExchangesEvent {
  const FetchExchanges();

  @override
  List<Object> get props => [];
}
