import 'package:equatable/equatable.dart';

class NewsEntry extends Equatable {
  final DateTime date;
  final String headline;
  final String source;
  final String link;

  const NewsEntry({this.date, this.headline, this.source, this.link});

  @override
  List<Object> get props => [
        date,
        headline,
        link,
      ];

  static NewsEntry fromJson(dynamic json) {
    final int date = json['datetime'];
    final DateTime dateTime =
        DateTime.fromMicrosecondsSinceEpoch(date, isUtc: true);

    var headline = json['headline'];
    var source = json['source'];
    var link = json['url'];

    return NewsEntry(
        date: dateTime, headline: headline, source: source, link: link);
  }
}

class StockNews extends Equatable {
  final List<NewsEntry> newsEntries = List<NewsEntry>();

  StockNews();

  @override
  List<Object> get props => [newsEntries];

  static StockNews fromJson(dynamic json) {
    StockNews stockNews = StockNews();
    for (dynamic entry in json) {
      NewsEntry newsEntry = NewsEntry.fromJson(entry);
      stockNews.newsEntries.add(newsEntry);
    }

    return stockNews;
  }
}
