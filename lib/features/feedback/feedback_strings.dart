import '../../core/localization/app_dil.dart';

/// Geri bildirim özelliğinin metinleri (TR + EN).
abstract final class FeedbackStrings {
  /// Akşam bildirimi ve feedback ekranının ana sorusu.
  static String aksamSorusu(AppDil dil) =>
      dil.sec('Bugün gerçekten şanslı mıydın?', 'Were you really lucky today?');

  /// Feedback ekranının başlığı.
  static String baslik(AppDil dil) =>
      dil.sec('Günün nasıldı?', 'How was your day?');

  /// Olumlu seçenek emojisi (dil-nötr).
  static const String evetEmoji = '👍';

  /// Olumsuz seçenek emojisi (dil-nötr).
  static const String hayirEmoji = '👎';

  /// Opsiyonel emoji bölümünün başlığı.
  static String emojiBaslik(AppDil dil) =>
      dil.sec('İstersen bir emoji bırak', 'Leave an emoji if you like');

  /// Seçilebilir duygu emojileri (dil-nötr).
  static const List<String> emojiSecenekleri = <String>[
    '🍀',
    '✨',
    '😐',
    '😅',
    '😮',
    '🥲',
  ];

  /// Kaydet butonu.
  static String kaydet(AppDil dil) => dil.sec('Kaydet', 'Save');

  /// Kayıt sonrası teşekkür metni.
  static String tesekkur(AppDil dil) =>
      dil.sec('Kaydedildi, yarın görüşürüz ✨', 'Saved, see you tomorrow ✨');

  /// Bildirim izni reddedildiğinde gösterilen nazik hatırlatma.
  static String izinReddiMesaji(AppDil dil) => dil.sec(
    'Sorun değil! İstersen bildirimleri daha sonra '
        'telefon ayarlarından açabilirsin.',
    'No problem! You can turn on notifications later from your '
        'phone settings.',
  );
}
