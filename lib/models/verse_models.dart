class VerseOfDay {
  final String reference;
  final String text;

  VerseOfDay({
    required this.reference,
    required this.text,
  });

  factory VerseOfDay.fromMap(Map<String, dynamic> data) {
    return VerseOfDay(
      reference: data['reference'] ?? '',
      text: data['text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      'text': text,
    };
  }
}
