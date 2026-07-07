/// Geri bildirim ve bildirim özelliğine özgü sabitler.
abstract final class FeedbackConfig {
  /// Akşam bildirimi saati (21:00).
  static const int aksamSaat = 21;

  /// Akşam bildirimi dakikası.
  static const int aksamDakika = 0;

  /// Sabah bildirimi saati (08:30).
  static const int sabahSaat = 8;

  /// Sabah bildirimi dakikası.
  static const int sabahDakika = 30;

  /// Sabah bildirimleri kaç gün ileriye planlanır (her açılışta
  /// pencere tazelenir; metin varyasyonu güne göre değişir).
  static const int sabahGunSayisi = 14;

  /// Akşam bildiriminin sabit kimliği.
  static const int aksamBildirimId = 200;

  /// Sabah bildirimlerinin başlangıç kimliği (100, 101, ...).
  static const int sabahBildirimBaslangicId = 100;

  /// Bildirime dokunulduğunda feedback ekranını açan payload.
  static const String feedbackPayload = 'aksam_feedback';

  /// Android bildirim kanalı kimliği.
  static const String kanalId = 'kader_gunluk';

  /// Android bildirim kanalı adı.
  static const String kanalAd = 'Günlük Hatırlatmalar';

  /// Android bildirim kanalı açıklaması.
  static const String kanalAciklama =
      'Sabah kader hazır ve akşam geri bildirim hatırlatmaları';

  /// Feedback ekranındaki büyük seçim butonlarının boyutu.
  static const double secimButonBoyutu = 96;

  /// Büyük seçim emoji puntosu.
  static const double secimEmojiPunto = 40;
}
