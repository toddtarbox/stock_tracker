import 'package:equatable/equatable.dart';

class IntraDayEntry extends Equatable {
  final DateTime date;
  final String label;
  final double close;

  const IntraDayEntry({this.date, this.label, this.close});

  @override
  List<Object> get props => [
        date,
        label,
        close,
      ];

  static IntraDayEntry fromJson(dynamic json) {
    final String date = json['date'];
    final String time = json['minute'];
    final DateTime dateTime = DateTime.parse(date + ' ' + time);

    final label = json['label'];

    var close = json['close'];
    if (close == null) {
      return null;
    }

    return IntraDayEntry(date: dateTime, label: label, close: close.toDouble());
  }
}

class StockIntraDay extends Equatable {
  final List<IntraDayEntry> intraDayEntries = List<IntraDayEntry>();

  StockIntraDay();

  @override
  List<Object> get props => [intraDayEntries];

  static StockIntraDay fromJson(dynamic json) {
    StockIntraDay stockIntraDay = StockIntraDay();
    for (dynamic entry in json) {
      IntraDayEntry intraDayEntry = IntraDayEntry.fromJson(entry);
      if (intraDayEntry != null) {
        stockIntraDay.intraDayEntries.add(intraDayEntry);
      }
    }

    return stockIntraDay;
  }
}
