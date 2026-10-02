/// Ayarlar ekranının Türkçe metinleri.
abstract final class AyarlarStrings {
  /// Ekran başlığı.
  static const String baslik = 'Ayarlar';

  /// Bölüm: profil.
  static const String profil = 'Profil';

  /// Ad satırı.
  static const String ad = 'Adın';

  /// Doğum tarihi satırı.
  static const String dogumTarihi = 'Doğum tarihin';

  /// Sabit alan açıklaması.
  static const String sabitAlanNotu =
      'Günlük skorun bu iki bilgiden hesaplandığı için değiştirilemez. '
      'Yanlış girdiysen verilerini silip yeniden başlayabilirsin.';

  /// Tam ad satırı.
  static const String tamAd = 'Doğumdaki tam adın';

  /// Tam ad boşken.
  static const String tamAdYok = 'Eklenmedi — isim sayıların için ekle';

  /// Tercihler satırı.
  static const String tercihler = 'Tanışma cevapların';

  /// Tercihler açıklaması.
  static const String tercihlerAciklama =
      'Yorumlarının sana uyması için verdiğin cevaplar';

  /// Bölüm: premium.
  static const String premium = 'Premium';

  /// Premium aktif.
  static const String premiumAktif = 'Premium aktif';

  /// Premium değil.
  static const String premiumDegil = 'Ücretsiz sürüm';

  /// Premium'a geç satırı.
  static const String premiumaGec = 'Premium\'a geç';

  /// Abonelik yönetimi.
  static const String aboneligiYonet = 'Aboneliğini yönet';

  /// Geri yükleme.
  static const String geriYukle = 'Satın alımları geri yükle';

  /// Bölüm: bildirimler.
  static const String bildirimler = 'Bildirimler';

  /// Bildirim saatleri.
  static const String bildirimSaatleri = 'Sabah 08:30 · Akşam 21:00';

  /// Bildirim açıklaması.
  static const String bildirimAciklama =
      'Bildirimleri kapatmak için telefonunun Ayarlar > Uygulamalar > Kader '
      '> Bildirimler bölümünü kullanabilirsin.';

  /// Bildirim planlarını tazele.
  static const String bildirimleriTazele = 'Bildirimleri yeniden kur';

  /// Bildirimler kuruldu.
  static const String bildirimlerKuruldu = 'Bildirimler yeniden kuruldu.';

  /// Bölüm: gizlilik ve yasal.
  static const String gizlilikYasal = 'Gizlilik ve yasal';

  /// Reklam gizlilik tercihleri.
  static const String reklamGizlilik = 'Reklam gizlilik tercihleri';

  /// Uyarı metni satırı.
  static const String uyari = 'Uyarı: eğlence amaçlıdır';

  /// Verilerimi sil.
  static const String verileriSil = 'Verilerimi sil';

  /// Silme açıklaması.
  static const String verileriSilAciklama =
      'Profilin, günlük kayıtların, geri bildirimlerin ve eklediğin kişiler '
      'bu cihazdan kalıcı olarak silinir. Premium aboneliğin Google Play\'de '
      'devam eder; iptal için Google Play\'i kullanmalısın.';

  /// Silme onay başlığı.
  static const String silOnayBaslik = 'Tüm veriler silinsin mi?';

  /// Silme onayı butonu.
  static const String sil = 'Kalıcı olarak sil';

  /// Vazgeç.
  static const String vazgec = 'Vazgeç';

  /// Tamam.
  static const String tamam = 'Tamam';

  /// Bölüm: geliştirici (yalnız debug).
  static const String gelistirici = 'Geliştirici (yalnızca debug)';

  /// Premium simülasyonu.
  static const String premiumSimulasyonu = 'Premium simülasyonu';

  /// Rıza sıfırlama.
  static const String rizaSifirla = 'Reklam rıza durumunu sıfırla';

  /// Rıza sıfırlandı.
  static const String rizaSifirlandi =
      'Rıza durumu sıfırlandı; uygulamayı yeniden başlatınca form tekrar görünür.';

  /// Sürüm satırı.
  static String surum(String s) => 'Kader $s';
}
