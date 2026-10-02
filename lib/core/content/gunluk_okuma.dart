import '../luck_engine/luck_engine.dart';
import 'content_config.dart';
import 'sans_rengi.dart';

/// Günlük okumanın bölüm türleri.
enum OkumaBolumTuru {
  /// Günün sana etkisi: durum, doğanla buluşması, sahne ve öneri.
  enerji,

  /// Günün en parlak kategorisi.
  parlayan,

  /// Günün en zayıf kategorisi için dikkat notu.
  dikkat,
}

/// Okumanın tek bir bölümü.
class OkumaBolumu {
  /// Tüm alanlarıyla bölüm oluşturur.
  const OkumaBolumu({
    required this.tur,
    required this.kimlik,
    required this.metin,
    this.kategori,
  });

  /// Bölümün türü.
  final OkumaBolumTuru tur;

  /// Geri bildirim için kararlı kimlik ("enerji:1a2b3c4d").
  ///
  /// Bölümün ana varyantının metin özetidir; kullanıcı "bu beni
  /// anlatmadı" dediğinde sonraki günlerde bu varyant ayıklanır.
  final String kimlik;

  /// Slotları doldurulmuş, gösterime hazır metin.
  final String metin;

  /// Parlayan/dikkat bölümlerinde ilgili kategori.
  final LuckCategory? kategori;
}

/// "Neden bugün?" açıklama öğesinin türü.
enum NedenTuru {
  /// Ay evresi modifiyeri.
  ayEvresi,

  /// Takvim gününün numerolojisi modifiyeri.
  gunSayisi,

  /// Düşük seriyi telafi eden denge modifiyeri.
  seriDengesi,

  /// Kişisel gün sayısı.
  kisiselGun,

  /// Kişisel gün ile yaşam yolunun çakışması.
  cakisma,
}

/// "Neden bugün?" çipinin verisi.
class NedenOgesi {
  /// Tüm alanlarıyla öğe oluşturur.
  const NedenOgesi({
    required this.tur,
    required this.etiket,
    required this.aciklama,
    this.etki,
  });

  /// Öğenin türü.
  final NedenTuru tur;

  /// Çipte gösterilen kısa etiket.
  final String etiket;

  /// Dokununca açılan açıklama metni.
  final String aciklama;

  /// Skora puan etkisi (varsa).
  final int? etki;
}

/// Bir günün kişiye özel, bölümlü okuması.
///
/// Persist edilmez; saklanan [LuckResult], sabit profil ve önceki
/// günlerin geri bildiriminden her açılışta aynı şekilde türetilir.
class GunlukOkuma {
  /// Tüm alanlarıyla okuma oluşturur.
  const GunlukOkuma({
    required this.baslik,
    required this.dongu,
    required this.bolumler,
    required this.kapanis,
    required this.nedenler,
    required this.sansRengi,
    required this.sansliSayi,
    required this.tavsiye,
    required this.parlayanKategori,
    required this.dikkatKategori,
    required this.sansliSaat,
  });

  /// Günün başlığı ("Temel Atma Günü").
  final String baslik;

  /// Günün kişisel döngüleri.
  final GunDongusu dongu;

  /// Sıralı bölümler: enerji, parlayan, dikkat.
  final List<OkumaBolumu> bolumler;

  /// Kapanış cümlesi.
  final String kapanis;

  /// "Neden bugün?" öğeleri.
  final List<NedenOgesi> nedenler;

  /// Günün şans rengi.
  final SansRengi sansRengi;

  /// Günün şanslı sayısı.
  final int sansliSayi;

  /// Günün tavsiyesi.
  final String tavsiye;

  /// Günün en yüksek skorlu kategorisi.
  final LuckCategory parlayanKategori;

  /// Günün en düşük skorlu kategorisi.
  final LuckCategory dikkatKategori;

  /// Parlayan kategorinin şanslı saat aralığı.
  final SansliSaat sansliSaat;

  /// Tüm okumanın düz metni (kelime sayımı için).
  String get tamMetin => <String>[
    for (final OkumaBolumu b in bolumler) b.metin,
    kapanis,
  ].join(' ');

  /// Ekranda tek yorum kartında gösterilen metin: bölümler paragraf
  /// paragraf, en sonda dönem cümlesi.
  String get kartMetni => <String>[
    for (final OkumaBolumu b in bolumler) b.metin,
    kapanis,
  ].join('\n\n');
}

/// Kategori detay sayfasının okuması.
class KategoriOkumasi {
  /// Tüm alanlarıyla okuma oluşturur.
  const KategoriOkumasi({
    required this.kategori,
    required this.skor,
    required this.ton,
    required this.paragraf,
    required this.eylem,
    required this.sansliSaat,
  });

  /// Kategori.
  final LuckCategory kategori;

  /// Kategorinin bugünkü skoru.
  final int skor;

  /// Skorun tonu.
  final KategoriTonu ton;

  /// Ana paragraf (durum + günün etkisi + kişinin tarzı + tavsiye).
  final String paragraf;

  /// Şanslı saatli eylem önerisi.
  final String eylem;

  /// Şanslı saat aralığı.
  final SansliSaat sansliSaat;
}

/// Kader Profili ekranının bölüm türleri (sıra = ekrandaki sıra).
enum ProfilBolumTuru {
  /// Yaşam yolu özü.
  oz,

  /// Güçlü yanlar.
  gucluYanlar,

  /// Güneş burcu.
  burc,

  /// Gölge yan.
  golgeYan,

  /// Aşkta.
  askta,

  /// İş ve para.
  isteVeParada,

  /// Yaşam dersi.
  yasamDersi,

  /// Ruh sayısı (iç ses).
  icSes,

  /// İsim + kişilik sayısı (dünyaya yansıma).
  yansima,

  /// Kişisel yıl.
  yil,
}

/// Kader Profili'nin tek bölümü.
class ProfilBolumu {
  /// Tüm alanlarıyla bölüm oluşturur.
  const ProfilBolumu({
    required this.tur,
    required this.baslik,
    required this.metin,
    required this.premium,
  });

  /// Bölüm türü.
  final ProfilBolumTuru tur;

  /// Bölüm başlığı.
  final String baslik;

  /// Gösterime hazır metin.
  final String metin;

  /// Premium (veya reklamla açılan) içerik mi?
  final bool premium;
}

/// Uyum okumasının tek bölümü.
class UyumBolumu {
  /// [baslik] ve [metin] ile bölüm oluşturur.
  const UyumBolumu({required this.baslik, required this.metin});

  /// Bölüm başlığı.
  final String baslik;

  /// Gösterime hazır metin.
  final String metin;
}

/// İki kişi arasındaki uyum okuması.
class UyumOkumasi {
  /// [sonuc] ve [bolumler] ile okuma oluşturur.
  const UyumOkumasi({required this.sonuc, required this.bolumler});

  /// Hesaplanan uyum sonucu.
  final UyumSonucu sonuc;

  /// Sıralı okuma bölümleri.
  final List<UyumBolumu> bolumler;
}
