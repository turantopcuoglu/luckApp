/// Geri bildirim özelliğinin Türkçe metinleri.
abstract final class FeedbackStrings {
  /// Akşam bildirimi ve feedback ekranının ana sorusu.
  static const String aksamSorusu = 'Bugün gerçekten şanslı mıydın?';

  /// Feedback ekranının başlığı.
  static const String baslik = 'Günün nasıldı?';

  /// Olumlu seçenek emojisi.
  static const String evetEmoji = '👍';

  /// Olumsuz seçenek emojisi.
  static const String hayirEmoji = '👎';

  /// Opsiyonel emoji bölümünün başlığı.
  static const String emojiBaslik = 'İstersen bir emoji bırak';

  /// Seçilebilir duygu emojileri.
  static const List<String> emojiSecenekleri = <String>[
    '🍀',
    '✨',
    '😐',
    '😅',
    '😮',
    '🥲',
  ];

  /// Kaydet butonu.
  static const String kaydet = 'Kaydet';

  /// Kayıt sonrası teşekkür metni.
  static const String tesekkur = 'Kaydedildi, yarın görüşürüz ✨';

  /// Bildirim izni reddedildiğinde gösterilen nazik hatırlatma.
  static const String izinReddiMesaji =
      'Sorun değil! İstersen bildirimleri daha sonra '
      'telefon ayarlarından açabilirsin.';
}
