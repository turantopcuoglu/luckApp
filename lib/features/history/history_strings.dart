import '../../core/localization/app_dil.dart';

/// Geçmiş ekranının metinleri (TR + EN).
abstract final class HistoryStrings {
  /// Ekran başlığı.
  static String baslik(AppDil dil) => dil.sec('Geçmiş', 'History');

  /// Boş durum başlığı (henüz kayıt yok).
  static String bosBaslik(AppDil dil) =>
      dil.sec('Henüz geçmişin yok', 'You have no history yet');

  /// Boş durum açıklaması.
  static String bosMetin(AppDil dil) => dil.sec(
    'Her gün kaderine baktıkça burada şans haritan oluşacak.',
    'As you check your fortune each day, your luck map will grow here.',
  );

  /// Kanıt Döngüsü kartının başlığı.
  static String kanitBasligi(AppDil dil) =>
      dil.sec('Kanıt Döngüsü', 'Proof Loop');

  /// Kanıt Döngüsü kartının alt açıklaması.
  static String kanitAciklama(AppDil dil) => dil.sec(
    'Sana söylediğimiz ile senin hissettiğin ne kadar örtüşüyor?',
    'How well does what we told you match what you felt?',
  );

  /// Toplam gün istatistiği etiketi.
  static String toplamGunEtiketi(AppDil dil) =>
      dil.sec('Kayıtlı gün', 'Days logged');

  /// Ortalama skor istatistiği etiketi.
  static String ortalamaSkorEtiketi(AppDil dil) =>
      dil.sec('Ortalama skor', 'Average score');

  /// En şanslı gün istatistiği etiketi.
  static String enSansliGunEtiketi(AppDil dil) =>
      dil.sec('En şanslı günün', 'Your luckiest day');

  /// Yeterli kanıt varken gösterilen ana cümle.
  ///
  /// [n] yüksek skorlu geri bildirimli gün sayısı, [yuzde] pozitif oranı.
  static String kanitMetni(AppDil dil, int n, int yuzde) => dil.sec(
    'Sana yüksek skor verdiğimiz $n günün %$yuzde\'inde sen de günü '
        'gerçekten şanslı buldun.',
    'On $yuzde% of the $n days we gave you a high score, you also '
        'found the day truly lucky.',
  );

  /// Yeterli örnek toplanmadığında gösterilen "kayıt biriktir" cümlesi.
  ///
  /// [esik] gereken en az gün, [n] şu ana kadar toplanan örnek.
  static String kanitYetersizMetni(AppDil dil, int esik, int n) => dil.sec(
    'Kanıt döngüsü için yüksek skorlu en az $esik güne akşam geri '
        'bildirimi gerek — şu ana kadar $n.',
    'The proof loop needs evening feedback on at least $esik '
        'high-score days — $n so far.',
  );

  /// Heatmap hücresine dokununca çıkan detay ($tarih • skor $skor).
  static String hucreDetay(AppDil dil, String tarih, int skor) =>
      dil.sec('$tarih • skor $skor', '$tarih • score $skor');

  /// Heatmap hücresinin ekran okuyucu (erişilebilirlik) etiketi.
  static String hucreErisim(AppDil dil, String tarih, int skor) =>
      dil.sec('$tarih, skor $skor', '$tarih, score $skor');
}
