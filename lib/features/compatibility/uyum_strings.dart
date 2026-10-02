/// Uyum özelliğinin Türkçe metinleri.
abstract final class UyumStrings {
  /// Ekran başlığı.
  static const String baslik = 'Uyum';

  /// Açıklama.
  static const String aciklama =
      'Partnerin, hoşlandığın biri, bir arkadaşın ya da ailenden biriyle '
      'sayılarınızın ve burçlarınızın uyumunu gör.';

  /// Boş durum.
  static const String bosDurum =
      'Henüz kimseyi eklemedin. İlk kişiyi ekleyerek uyumunuzu keşfet.';

  /// Kişi ekle butonu.
  static const String kisiEkle = 'Kişi ekle';

  /// Form başlığı.
  static const String formBaslik = 'Yeni kişi';

  /// Ad alanı etiketi.
  static const String adEtiketi = 'Tam adı';

  /// Ad alanı ipucu.
  static const String adIpucu = 'Ad Soyad (varsa göbek adıyla)';

  /// Doğum tarihi etiketi.
  static const String dogumEtiketi = 'Doğum tarihi';

  /// Rol etiketi.
  static const String rolEtiketi = 'Senin için kim?';

  /// Kaydet.
  static const String kaydet = 'Uyumu hesapla';

  /// Ad boş uyarısı.
  static const String adBos = 'Devam etmek için adı yazmalısın.';

  /// Bilgi notu.
  static const String rizaNotu =
      'Bilgiler yalnızca bu cihazda saklanır. Başka birinin bilgilerini '
      'eklerken onun da haberdar olmasına özen göster.';

  /// Silme onayı başlığı.
  static String silBaslik(String ad) => '$ad silinsin mi?';

  /// Sil.
  static const String sil = 'Sil';

  /// Vazgeç.
  static const String vazgec = 'Vazgeç';

  /// Sonuç ekranı skor etiketi.
  static const String uyumEtiketi = 'UYUM';

  /// Sonuç notu.
  static const String sonucNotu =
      'Uyum; iki kişinin yaşam yolu sayıları, burç elementleri ve (tam adlar '
      'biliniyorsa) ruh sayıları üzerinden geleneksel numeroloji kurallarıyla '
      'hesaplanır. İlişkinin geleceği hakkında hüküm vermez; eğlence amaçlıdır.';

  /// Kişi kartı alt satırı.
  static String kisiOzeti({
    required String rol,
    required String burc,
    required int yasamYolu,
  }) =>
      '$rol · $burc · Yaşam yolu $yasamYolu';
}
