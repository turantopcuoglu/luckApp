/// Geçmiş ekranının Türkçe metinleri.
abstract final class HistoryStrings {
  /// Ekran başlığı.
  static const String baslik = 'Geçmiş';

  /// Boş durum başlığı (henüz kayıt yok).
  static const String bosBaslik = 'Henüz geçmişin yok';

  /// Boş durum açıklaması.
  static const String bosMetin =
      'Her gün kaderine baktıkça burada şans haritan oluşacak.';

  /// Kanıt Döngüsü kartının başlığı.
  static const String kanitBasligi = 'Kanıt Döngüsü';

  /// Kanıt Döngüsü kartının alt açıklaması.
  static const String kanitAciklama =
      'Sana söylediğimiz ile senin hissettiğin ne kadar örtüşüyor?';

  /// Toplam gün istatistiği etiketi.
  static const String toplamGunEtiketi = 'Kayıtlı gün';

  /// Ortalama skor istatistiği etiketi.
  static const String ortalamaSkorEtiketi = 'Ortalama skor';

  /// En şanslı gün istatistiği etiketi.
  static const String enSansliGunEtiketi = 'En şanslı günün';

  /// Yeterli kanıt varken gösterilen ana cümle.
  ///
  /// [n] yüksek skorlu geri bildirimli gün sayısı, [yuzde] pozitif oranı.
  static String kanitMetni(int n, int yuzde) =>
      'Sana yüksek skor verdiğimiz $n günün %$yuzde\'inde sen de günü '
      'gerçekten şanslı buldun.';

  /// Yeterli örnek toplanmadığında gösterilen "kayıt biriktir" cümlesi.
  ///
  /// [esik] gereken en az gün, [n] şu ana kadar toplanan örnek.
  static String kanitYetersizMetni(int esik, int n) =>
      'Kanıt döngüsü için yüksek skorlu en az $esik güne akşam geri '
      'bildirimi gerek — şu ana kadar $n.';

  /// Heatmap hücresine dokununca çıkan detay ($tarih • skor $skor).
  static String hucreDetay(String tarih, int skor) => '$tarih • skor $skor';
}
