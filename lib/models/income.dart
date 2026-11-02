
class Income {
  final String id;
  final double amount;
  final String source;
  final DateTime date;
  final String note;

  Income({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'source': source,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      source: json['source'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }
}
