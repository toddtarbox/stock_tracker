import 'package:equatable/equatable.dart';

class DayEntry extends Equatable {
  final DateTime date;
  final double close;

  const DayEntry({this.date, this.close});

  @override
  List<Object> get props => [
        date,
        close,
      ];

  static DayEntry fromJson(dynamic json) {
    final String date = json['date'];
    final DateTime dateTime = DateTime.parse(date);

    var close = json['close'];
    if (close == null) {
      return null;
    }

    return DayEntry(date: dateTime, close: close.toDouble());
  }
}

class StockHistoric extends Equatable {
  final List<DayEntry> dailyEntries = List<DayEntry>();

  StockHistoric();

  @override
  List<Object> get props => [dailyEntries];

  static StockHistoric fromJson(dynamic json) {
    StockHistoric stockHistoric = StockHistoric();
    for (dynamic entry in json) {
      DayEntry dayEntry = DayEntry.fromJson(entry);
      if (dayEntry != null) {
        stockHistoric.dailyEntries.add(dayEntry);
      }
    }

    return stockHistoric;
  }
}
