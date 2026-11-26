/// Kişiye özel okumaları havuzlardan deterministik biçimde birleştirir.
///
/// Yorum yönü (bkz. `yorum_yonu.dart`): her paragraf tek bir mantık
/// zinciri izler — bugün nasıl bir gün, bu gün senin doğanla nasıl
/// buluşuyor, hayatında nerede görünür, ne yapmalısın. Numeroloji
/// terimleri ana metinde kullanılmaz; yalnızca "Neden bugün?" öğelerinde
/// gerçek hesap değerleriyle açıklanır.
///
/// Kritik sözleşmeler:
/// - Tonlar SAKLANAN [LuckResult] skorlarından okunur — genel skor "seri
///   dengesi" yüzünden (kullanıcı, gün) çiftinden yeniden türetilemez.
/// - Varyant seçimleri motorun bağımsız içerik tohumlarından gelir
///   ([LuckEngine.donguselIndeks]); aynı (okuyucu, gün, saklanan sonuç,
///   önceki günlerin geri bildirimi) HER ZAMAN aynı metni üretir
///   (CLAUDE.md kural 8).
/// - Geri bildirim yalnızca [begenilmeyenler] üzerinden, ÖNCEKİ günlerin
///   kimlikleriyle etkiler; bugün verilen cevap bugünün metnini değiştirmez.
library;

import '../luck_engine/luck_engine.dart';
import 'burc_metinleri.dart';
import 'content_config.dart';
import 'dongu_metinleri.dart';
import 'fortune_pools.dart';
import 'gokyuzu_metinleri.dart';
import 'gunluk_okuma.dart';
import 'icerik_paketi.dart';
import 'kimlik_metinleri.dart';
import 'kisilik_metinleri.dart';
import 'kisisel_havuzlar.dart';
import 'neden_metinleri.dart';
import 'okuyucu.dart';
import 'sans_rengi.dart';
import 'sayi_metinleri.dart';
import 'slot_doldurucu.dart';
import 'tr_icerik_paketi.dart';
import 'uyum_metinleri.dart';
import 'yorum_yonu.dart';

/// Genel skor bandından günlük okuma tonunu bulur.
GunTonu gunTonuBul(int genelSkor) {
  switch (SkorBandi.bandiBul(genelSkor)) {
    case SkorBandi.cokDusuk:
    case SkorBandi.dusuk:
      return GunTonu.dusuk;
    case SkorBandi.orta:
      return GunTonu.orta;
    case SkorBandi.yuksek:
    case SkorBandi.cokYuksek:
      return GunTonu.yuksek;
  }
}

/// [okuyucu] için şablon yer tutucularının değer sözlüğünü kurar.
///
/// Adlar ve isim çekimi [paket]ten gelir (dil bağımsız erişim, E2).
Map<String, String> slotSozlugu(
  Okuyucu okuyucu, {
  DateTime? gun,
  GunDongusu? dongu,
  SansliSaat? saat,
  String? digerIsim,
  Burc? ayBurcu,
  IcerikPaketi paket = trIcerik,
}) {
  final KarakterYonu? karakter =
      YorumYonu.karakterler[okuyucu.profil.yasamYolu.deger];
  return <String, String>{
    SlotAnahtarlari.isim: okuyucu.isim,
    SlotAnahtarlari.isimIlgi: paket.iyelik(okuyucu.isim),
    SlotAnahtarlari.burc: paket.burcAdi(okuyucu.profil.burc),
    SlotAnahtarlari.yasamYolu: '${okuyucu.profil.yasamYolu.deger}',
    if (karakter != null) SlotAnahtarlari.doga: karakter.doga,
    if (dongu != null) SlotAnahtarlari.kisiselGun: '${dongu.kisiselGun}',
    if (dongu != null) SlotAnahtarlari.kisiselYil: '${dongu.kisiselYil}',
    if (dongu != null)
      SlotAnahtarlari.gunIstegi: YorumYonu.gunTemalari[dongu.kisiselGun]!.istek,
    if (gun != null) SlotAnahtarlari.yil: '${gun.year}',
    if (saat != null) SlotAnahtarlari.saat: saat.etiket,
    if (digerIsim != null) SlotAnahtarlari.digerIsim: digerIsim,
    if (ayBurcu != null) SlotAnahtarlari.ayBurcu: paket.burcAdi(ayBurcu),
  };
}

/// Geri bildirim kimliği: bölüm türü + varyant metninin kararlı özeti.
String bolumKimligi(OkumaBolumTuru tur, String varyant) =>
    '${tur.name}:${metinKimligi(varyant)}';

/// [havuz]dan, kullanıcının önceki günlerde beğenmediği varyantları
/// çıkarır; geriye [ContentConfig.enAzKalanVaryant]'tan azı kalırsa
/// havuzu olduğu gibi döndürür.
List<String> begenilenleriSec(
  List<String> havuz,
  OkumaBolumTuru tur,
  Set<String> begenilmeyenler,
) {
  if (begenilmeyenler.isEmpty) {
    return havuz;
  }
  final List<String> kalan = havuz
      .where((String m) => !begenilmeyenler.contains(bolumKimligi(tur, m)))
      .toList(growable: false);
  return kalan.length >= ContentConfig.enAzKalanVaryant ? kalan : havuz;
}

/// Çelişki kapısı: [havuz]dan [okuyucu]nun çekirdek portresiyle
/// ([Okuyucu.portre]) çelişen cümleleri çıkarır.
///
/// Günlük okuma ve kategori okumalarındaki HER metin havuzu seçimden önce
/// buradan geçer; böylece içe dönük birine "bir gruba fikrini sun", aklıyla
/// karar verene "ilk hissine güven", ilişki durumu bilinmeyene
/// "partnerin…" cümlesi seçilemez. Geriye [enAz]'dan az cümle kalırsa
/// havuz olduğu gibi döner (bkz. [KisilikMetinleri.uyumlular]).
List<String> _kapi(Okuyucu okuyucu, List<String> havuz, {int enAz = 1}) =>
    KisilikMetinleri.uyumlular(havuz, okuyucu.portre, enAz: enAz);

/// Havuzdan deterministik ve döngü içinde tekrarsız eleman seçer.
///
/// Metin havuzları seçimden önce çelişki kapısından ([_kapi]) geçer.
T _sec<T>(
  LuckEngine motor,
  Okuyucu okuyucu,
  DateTime gun,
  String amac,
  List<T> aday, {
  int adimGun = 1,
}) {
  final Object ham = aday;
  final List<T> havuz = ham is List<String>
      ? _kapi(okuyucu, ham) as List<T>
      : aday;
  return havuz[motor.donguselIndeks(
    kullanici: okuyucu.seed,
    gun: gun,
    amac: amac,
    havuzBoyutu: havuz.length,
    adimGun: adimGun,
  )];
}

/// Döngü sınırında da ardışık iki günde tekrar etmeyen deterministik
/// indeks.
///
/// [LuckEngine.donguselIndeks] bir döngü içinde tekrarsızdır; yalnızca yeni
/// döngünün ilk elemanı öncekinin sonuncusuyla aynı olabilir. Bu durumda
/// yeni döngünün ilk iki elemanı yer değiştirir. Üç ve daha büyük
/// havuzlarda önceki döngünün son elemanı bu değişimden etkilenmediği için
/// kural her gün için aynı sonucu verir (geriye sınırsız bakmaya gerek
/// yoktur). İki elemanlı havuzlarda değişim yapılmaz.
int _ardisikTekrarsizIndeks(
  LuckEngine motor,
  Okuyucu okuyucu,
  DateTime gun,
  String amac,
  int havuzBoyutu,
) {
  int ham(int gunFarki) => motor.donguselIndeks(
    kullanici: okuyucu.seed,
    gun: DateTime(gun.year, gun.month, gun.day + gunFarki),
    amac: amac,
    havuzBoyutu: havuzBoyutu,
  );
  if (havuzBoyutu < ContentConfig.tekrarsizEnAzHavuz) {
    return ham(0);
  }
  // donguselIndeks ile aynı konum hesabı (adım 1 gün).
  final int konum = LuckEngine.gunNumarasi(gun) % havuzBoyutu;
  if (konum == 0 && ham(0) == ham(-1)) {
    return ham(1);
  }
  if (konum == 1 && ham(-1) == ham(-2)) {
    return ham(-1);
  }
  return ham(0);
}

/// [skorlar] içindeki en yüksek skorlu kategoriyi döndürür.
///
/// Hive round-trip sonrası map'in ekleme sırası garanti olmadığından
/// karşılaştırma [LuckCategory.values] tanım sırasıyla yapılır;
/// eşitlikte enum sırasında önce gelen kazanır (deterministik).
LuckCategory baskinKategori(Map<LuckCategory, int> skorlar) {
  LuckCategory baskin = LuckCategory.values.first;
  int enYuksek = skorlar[baskin] ?? 0;
  for (final LuckCategory kategori in LuckCategory.values) {
    final int skor = skorlar[kategori] ?? 0;
    if (skor > enYuksek) {
      baskin = kategori;
      enYuksek = skor;
    }
  }
  return baskin;
}

/// [skorlar] içinde [haric] dışındaki en düşük skorlu kategori.
///
/// Eşitlikte enum sırasında önce gelen kazanır (deterministik).
LuckCategory enZayifKategori(
  Map<LuckCategory, int> skorlar, {
  required LuckCategory haric,
}) {
  LuckCategory? zayif;
  int enDusuk = EngineConfig.skorMaks + 1;
  for (final LuckCategory kategori in LuckCategory.values) {
    if (kategori == haric) {
      continue;
    }
    final int skor = skorlar[kategori] ?? 0;
    if (skor < enDusuk) {
      zayif = kategori;
      enDusuk = skor;
    }
  }
  return zayif!;
}

/// [okuyucu]nun yaşam yolu karakteri.
KarakterYonu _karakter(Okuyucu okuyucu) =>
    YorumYonu.karakterler[okuyucu.profil.yasamYolu.deger]!;

/// Bir kategori okumasının doldurulmuş parçaları (bkz.
/// `gokyuzu_metinleri.dart`).
class _GokyuzuParcalari {
  const _GokyuzuParcalari({
    required this.baslik,
    required this.gokyuzu,
    required this.gokyuzuSablonu,
    required this.kisilik,
    required this.sahne,
    required this.yap,
    required this.yapma,
  });

  /// Kısa başlık.
  final String baslik;

  /// Ay burcu × kişinin burcu × ton cümlesi.
  final String gokyuzu;

  /// [gokyuzu]nun doldurulmamış şablonu: geri bildirim kimliği
  /// ([bolumKimligi]) bundan üretilir ki havuz süzgeciyle eşleşsin.
  final String gokyuzuSablonu;

  /// Kişinin kendini tanıyacağı kalıcı eğilim cümlesi: Güneş burcundan ya
  /// da yaşam yolu karakterinden, cevaplarıyla çelişmeyenler arasından.
  final String kisilik;

  /// Kişinin gündelik hayatından sahne cümlesi.
  final String sahne;

  /// "Yap" önerileri (varsa önce kişisel olan).
  final List<String> yap;

  /// "Yapma" önerileri.
  final List<String> yapma;
}

/// [kategori] için günün gökyüzü parçalarını seçer.
///
/// Ay'ın günlük burcunun elementi okuyucunun Güneş elementiyle
/// karşılaştırılır ve [ton] ile birleşir; sahne uğraşa, kişisel öneri
/// enerji/karar tarzına göre seçilir. [ek] verilirse seçimler ayrı bir
/// döngü kullanır (detay sayfası günlük kartla aynı cümleyi göstermesin).
/// [suz], gökyüzü cümlesi havuzuna geri bildirim süzgeci uygular.
_GokyuzuParcalari _gokyuzuParcalari({
  required LuckEngine motor,
  required Okuyucu okuyucu,
  required DateTime gun,
  required LuckCategory kategori,
  required KategoriTonu ton,
  required String Function(String) doldur,
  String? ek,
  List<String> Function(List<String>)? suz,
  int utcFarkiDakika = EngineConfig.varsayilanUtcFarkiDakika,
}) {
  final Burc ayBurcu = Astronomi.gununAyBurcu(
    gun,
    utcFarkiDakika: utcFarkiDakika,
  );
  final ElementIliskisi iliski = elementIliskisi(
    ayBurcu.element,
    okuyucu.profil.burc.element,
  );

  /// [havuz]dan tekrarsız seçim. Varyant motorun döngüsel indeksinden
  /// gelir; ardışık iki günde aynı cümle gelmesin diye dünkü seçim (aynı
  /// kuralla, [ContentConfig.tekrarGeriBakis] gün geriye bakılarak
  /// hesaplanır) dışlanır. Detay sayfasında ([ek] verilmişse) aynı gün
  /// günlük kartta gösterilen cümle de dışlanır. Döngü sınırlarında eşit
  /// boyutlu havuzlar aynı anda tekrar edebildiği için bu kural gereklidir.
  String sec(List<String> havuz, String alan, String alt) {
    String amacEtiketi(String? e) => <String>[
      ContentConfig.kategoriAmaci(kategori, alan),
      alt,
      if (e != null) e,
    ].join(':');
    // Ham (döngüsel) indeksler derinlikten bağımsızdır; özyineleme aynı
    // günü birden çok kez sorduğu için önbelleğe alınır.
    final Map<String, int> hamOnbellek = <String, int>{};
    int ham(DateTime g, String? e) => hamOnbellek.putIfAbsent(
      '${g.year}-${g.month}-${g.day}:${e ?? ''}',
      () => motor.donguselIndeks(
        kullanici: okuyucu.seed,
        gun: g,
        amac: amacEtiketi(e),
        havuzBoyutu: havuz.length,
      ),
    );
    String kuralli(DateTime g, String? e, int derinlik) {
      final int h = ham(g, e);
      if (derinlik == 0) {
        return havuz[h];
      }
      final Set<String> haric = <String>{
        kuralli(DateTime(g.year, g.month, g.day - 1), e, derinlik - 1),
        if (e != null) kuralli(g, null, derinlik - 1),
      };
      for (int i = 0; i < havuz.length; i++) {
        final String aday = havuz[(h + i) % havuz.length];
        if (!haric.contains(aday)) {
          return aday;
        }
      }
      return havuz[h];
    }

    return kuralli(gun, ek, ContentConfig.tekrarGeriBakis);
  }

  // [baslangic] öğesinden itibaren havuzdan sırayla [adet] öğe (aynı gün
  // aynı öneri iki kez gösterilmesin diye), [haric] atlanarak.
  List<String> ardisik(
    List<String> havuz,
    String baslangic,
    int adet, {
    Set<String> haric = const <String>{},
  }) {
    final int ilk = havuz.indexOf(baslangic);
    return <String>[
      for (int i = 0; i < havuz.length; i++)
        if (!haric.contains(havuz[(ilk + i) % havuz.length]))
          havuz[(ilk + i) % havuz.length],
    ].take(adet).toList(growable: false);
  }

  // Bu fonksiyondaki bütün havuzlar çelişki kapısından geçer.
  List<String> kapi(List<String> havuz, {int enAz = 1}) =>
      _kapi(okuyucu, havuz, enAz: enAz);

  final List<String> gokyuzuHavuzu = kapi(
    GokyuzuMetinleri.gokyuzu[kategori]![iliski]![ton]!,
  );
  final String gokyuzu = sec(
    suz == null ? gokyuzuHavuzu : suz(gokyuzuHavuzu),
    ContentConfig.amacGokyuzu,
    '${iliski.name}:${ton.name}',
  );

  // Kişilik: günlük kartta çift günlerde burç, tek günlerde yaşam yolu
  // cümlesi; detay sayfasında tersi. Böylece okuyucu aynı gün hem burcunu
  // hem sayısını tanır ve iki ekran aynı cümleyi göstermez. Yaşam yolu
  // havuzunda cevaplarla uyumlu yeterli cümle yoksa burç kullanılır.
  final List<String> sayiUyumlu = <String>[
    for (final String m in _karakter(okuyucu).kategoriTarzi[kategori]!)
      if (!KisilikMetinleri.celisir(m, okuyucu.portre)) m,
  ];
  final bool sayiYeterli =
      sayiUyumlu.length >= ContentConfig.enAzKisilikSecenegi;
  final bool siraBurcta =
      (LuckEngine.gunNumarasi(gun) % ContentConfig.kisilikDonusumu == 0) ==
      (ek == null);
  final bool burcCumlesi = siraBurcta || !sayiYeterli;
  // Kişilik havuzları gün aşırı kullanıldığı için döngü kullanım aralığıyla
  // kurulur (adimGun): ardışık kullanımlar döngüde ardışık konumlara düşer
  // ve cümleler eşit sıklıkla döner.
  final List<String> kisilikHavuzu = burcCumlesi
      ? kapi(KisilikMetinleri.burc[okuyucu.profil.burc]![kategori]!)
      : sayiUyumlu;
  int kisilikIndeksi = motor.donguselIndeks(
    kullanici: okuyucu.seed,
    gun: gun,
    amac: burcCumlesi
        ? '${ContentConfig.kategoriAmaci(kategori, ContentConfig.amacKisilikBurc)}:${okuyucu.profil.burc.name}'
        : '${ContentConfig.kategoriAmaci(kategori, ContentConfig.amacKisilikSayi)}:${okuyucu.profil.yasamYolu.deger}',
    havuzBoyutu: kisilikHavuzu.length,
    adimGun: ContentConfig.kisilikDonusumu,
  );
  // Yaşam yolu havuzu yetersizse iki ekran da burç cümlesi kullanır;
  // detay sayfası o zaman günlük karttakinin bir sonrakini gösterir.
  if (ek != null && !sayiYeterli) {
    kisilikIndeksi = (kisilikIndeksi + 1) % kisilikHavuzu.length;
  }
  final String kisilik = kisilikHavuzu[kisilikIndeksi];

  final SahneYonu yon = SahneYonu.tondan(ton);
  final List<String> sahneHavuzu = kapi(
    GokyuzuMetinleri.sahneler[kategori]![yon]!,
  );
  final String sahne = sec(
    sahneHavuzu,
    ContentConfig.amacKategoriSahne,
    // "genel" ön eki eski tohumla aynı seçimi verir (K7 öncesi anahtar).
    '${GokyuzuMetinleri.genelAnahtar}:${yon.name}',
  );

  final String baslik = sec(
    kapi(GokyuzuMetinleri.basliklar[kategori]![ton]!),
    ContentConfig.amacKategoriBaslik,
    ton.name,
  );

  // Yap / Yapma listeleri sabit sayıda öneri gösterir; kapıdan en az o
  // kadar cümle çıkmalıdır.
  final List<String> genelYap = kapi(
    GokyuzuMetinleri.yap[kategori]![ton]!,
    enAz: ContentConfig.gokyuzuYapSayisi,
  );
  final List<String> yap = ardisik(
    genelYap,
    sec(genelYap, ContentConfig.amacYap, ton.name),
    ContentConfig.gokyuzuYapSayisi,
  );
  final List<String> yapmaHavuzu = kapi(
    GokyuzuMetinleri.yapma[kategori]![ton]!,
    enAz: ContentConfig.gokyuzuYapmaSayisi,
  );
  final List<String> yapma = ardisik(
    yapmaHavuzu,
    sec(yapmaHavuzu, ContentConfig.amacYapma, ton.name),
    ContentConfig.gokyuzuYapmaSayisi,
  );

  return _GokyuzuParcalari(
    baslik: doldur(baslik),
    gokyuzu: doldur(gokyuzu),
    gokyuzuSablonu: gokyuzu,
    kisilik: doldur(kisilik),
    sahne: doldur(sahne),
    yap: yap.map(doldur).toList(growable: false),
    yapma: yapma.map(doldur).toList(growable: false),
  );
}

/// Doldurulmuş bir gökyüzü cümlesinin Ay'ı anan ilk yarısı atılmış hâli.
///
/// Gökyüzü cümleleri "Ay burcu ve elementi; bu alana etkisi"
/// kalıbındadır. Günlük kartta Ay burcu açılış paragrafında zaten
/// anıldığı için kategori paragrafları onu tekrar etmez: eskiden aynı
/// okumada "Ay Yay burcunda, Balık burcunun elementine ters düşüyor"
/// üç kez geçiyor, metin makine işi gibi okunuyordu.
///
/// İkinci yarı ilkine bağlıysa ("bu gerilim …", "yine de …") tek başına
/// anlamsız kalır; o zaman null döner ve cümle o paragrafta hiç yer
/// almaz. Detay sayfası cümlenin tamamını gösterir.
String? ayOnekisizHali(String dolu) {
  final int ayrac = dolu.indexOf(ContentConfig.gokyuzuAyraci);
  if (ayrac < 0) {
    return null;
  }
  String kuyruk = dolu
      .substring(ayrac + ContentConfig.gokyuzuAyraci.length)
      .trim();
  // Yalnız açılış cümlesi "Bugün" diye başlar; ikinci yarının başındaki
  // "bugün" atılır ("bugün enerjin yüksek" → "Enerjin yüksek").
  if (kuyruk.startsWith(ContentConfig.bugunOneki)) {
    kuyruk = kuyruk.substring(ContentConfig.bugunOneki.length).trimLeft();
  }
  final String kucuk = kuyruk.toLowerCase();
  final bool bagimli =
      kuyruk.isEmpty ||
      ContentConfig.bagimliKuyrukBaslangiclari.any(kucuk.startsWith) ||
      ContentConfig.bagimliKuyrukIfadeleri.any(kucuk.contains);
  if (bagimli) {
    return null;
  }
  // Türkçe büyük harf: i → İ, ı → I.
  final String ilk = kuyruk[0];
  final String buyukIlk = switch (ilk) {
    'i' => 'İ',
    'ı' => 'I',
    _ => ilk.toUpperCase(),
  };
  return '$buyukIlk${kuyruk.substring(1)}';
}

/// [okuyucu] için [sonuc] gününün tam, bölümlü okumasını üretir.
///
/// [begenilmeyenler]: kullanıcının BU GÜNDEN ÖNCE "beni anlatmadı" dediği
/// bölüm kimlikleri (bkz. [bolumKimligi]). [paket]: içerik dili
/// (varsayılan Türkçe; bkz. `icerik_paketi.dart` geçiş notu).
GunlukOkuma gunlukOkuma({
  required LuckEngine motor,
  required Okuyucu okuyucu,
  required LuckResult sonuc,
  Set<String> begenilmeyenler = const <String>{},
  IcerikPaketi paket = trIcerik,
}) {
  final DateTime gun = sonuc.gun;
  final GunDongusu dongu = GunDongusu.hesapla(
    dogumTarihi: okuyucu.profil.dogumTarihi,
    gun: gun,
    utcFarkiDakika: sonuc.utcFarkiDakika,
  );
  final int k = dongu.kisiselGun;
  final GunTonu gunTonu = gunTonuBul(sonuc.genelSkor);
  final KarakterYonu karakter = _karakter(okuyucu);
  final BulusmaTuru bulusma = karakter.bulusma(k);

  final LuckCategory parlayan = baskinKategori(sonuc.kategoriSkorlari);
  final SansliSaat saat = motor.sansliSaat(
    kullanici: okuyucu.seed,
    gun: gun,
    kategori: parlayan,
  );
  final Map<String, String> slotlar = slotSozlugu(
    okuyucu,
    gun: gun,
    dongu: dongu,
    saat: saat,
    ayBurcu: Astronomi.gununAyBurcu(gun, utcFarkiDakika: sonuc.utcFarkiDakika),
    paket: paket,
  );
  String doldur(String s) => slotDoldur(s, slotlar);

  // ---- Başlık ----
  final String baslik = _sec(
    motor,
    okuyucu,
    gun,
    '${ContentConfig.amacBaslik}:$k',
    DonguMetinleri.gunBasliklari[k]!,
    adimGun: ContentConfig.kisiselGunAdimi,
  );

  // ---- Günün sana etkisi: durum → buluşma → sahne → öneri ----
  final String gunDurumu = _sec(
    motor,
    okuyucu,
    gun,
    '${ContentConfig.amacEnerji}:$k:${gunTonu.name}',
    // Günün durumu da okuyucunun cevaplarıyla çelişmeyenlerden seçilir
    // (ör. yalnız kalınca toparlanan birine "insanlarla temas kurmak seni
    // canlandıracak" denmez).
    begenilenleriSec(
      _kapi(okuyucu, YorumYonu.gunTemalari[k]!.durum[gunTonu]!),
      OkumaBolumTuru.enerji,
      begenilmeyenler,
    ),
    adimGun: ContentConfig.kisiselGunAdimi,
  );
  final String bulusmaCumlesi = _sec(
    motor,
    okuyucu,
    gun,
    '${ContentConfig.amacBulusma}:${bulusma.name}',
    YorumYonu.bulusmaCumleleri[bulusma]!,
  );
  final String sahne = _sec(
    motor,
    okuyucu,
    gun,
    '${ContentConfig.amacSahne}:$k',
    YorumYonu.gunSahneleri[k]!,
    adimGun: ContentConfig.kisiselGunAdimi,
  );
  // Öneri: buluşma türü ayın belirli kişisel günlerine denk geldiği için
  // takvim günüyle dönen bir seçim aynı varyantı aynı günlere tekrar
  // tekrar düşürür. Taban indeks kişisel gün adımıyla (~9 gün) döner,
  // kişisel gün de ötelemeye eklenir: ardışık günler (k, k+1) farklı
  // varyant alır, aynı kişisel gün sonraki dönemde başka varyant görür.
  // Öneriler de okuyucunun cevaplarıyla çelişmeyenler arasından seçilir
  // (ör. insanlarla beslenen birine "yalnız kalma ihtiyacını koru" denmez).
  final List<String> oneriler = _kapi(okuyucu, karakter.tavsiyeler(bulusma));
  final int oneriTabani = motor.donguselIndeks(
    kullanici: okuyucu.seed,
    gun: gun,
    amac: '${ContentConfig.amacOneri}:${bulusma.name}',
    havuzBoyutu: oneriler.length,
    adimGun: ContentConfig.kisiselGunAdimi,
  );
  final String oneri = oneriler[(oneriTabani + k) % oneriler.length];
  // Günün gökyüzü cümlesi: Ay'ın günlük burcu × okuyucunun Güneş burcu ×
  // günün tonu. Açılışın hemen ardından gelir ki okuyucu günü önce kendi
  // burcuyla tanısın.
  final Burc ayBurcu = Astronomi.gununAyBurcu(
    gun,
    utcFarkiDakika: sonuc.utcFarkiDakika,
  );
  final ElementIliskisi gunIliskisi = elementIliskisi(
    ayBurcu.element,
    okuyucu.profil.burc.element,
  );
  final List<String> gunGokyuzuHavuzu = _kapi(
    okuyucu,
    GokyuzuMetinleri.gunler[gunIliskisi]![gunTonu]!,
  );
  final String gunGokyuzuAmaci =
      '${ContentConfig.amacGunGokyuzu}:${gunIliskisi.name}:${gunTonu.name}';
  // Ay 2-3 gün aynı burçta kalır; aynı cümle art arda iki gün gelmesin.
  final String gunGokyuzu =
      gunGokyuzuHavuzu[_ardisikTekrarsizIndeks(
        motor,
        okuyucu,
        gun,
        gunGokyuzuAmaci,
        gunGokyuzuHavuzu.length,
      )];

  // Paragraf kısa kalsın diye numerolojinin "doğanla buluşma" cümlesi ve
  // gündelik sahne gün aşırı dönüşümlü yer alır. Buluşma cümlesi yaşam
  // yolunun sesidir; kategori paragraflarındaki kişilik cümlesinin de
  // yaşam yolundan geldiği günlere denk getirilir. Böylece bir gün TEK
  // sesle konuşur: ya burç ya sayı. Eskiden aynı okumada "doğan düzen
  // kurmak" (yaşam yolu 4) ile "aşkı bir masal gibi yaşarsın" (Balık)
  // yan yana düşüyor, okur iki farklı insanın tarif edildiğini sanıyordu.
  final bool bulusmaGunu =
      LuckEngine.gunNumarasi(gun) % ContentConfig.kisilikDonusumu != 0;
  // Sayı sesinin konuşmadığı günlerde, doğum haritası biliniyorsa gündelik
  // sahnenin yerini kişinin portresi alır: yükselenin dışarıya gösterdiği
  // yüz ile Ay burcunun iç dünyası (bkz. KimlikMetinleri). Portre gün
  // aşırı kullanıldığı için döngü o aralıkla kurulur (adimGun): ardışık
  // kullanımlar farklı cümleye düşer.
  final List<String> portreHavuzu = KimlikMetinleri.portreler(
    dogumAyi: okuyucu.dogumAyi,
    yukselen: okuyucu.yukselen,
  );
  final String? portre = portreHavuzu.isEmpty
      ? null
      : _sec(
          motor,
          okuyucu,
          gun,
          ContentConfig.amacPortre,
          portreHavuzu,
          adimGun: ContentConfig.kisilikDonusumu,
        );
  final String enerjiMetni = <String>[
    gunDurumu,
    gunGokyuzu,
    if (bulusmaGunu) bulusmaCumlesi else portre ?? sahne,
    oneri,
  ].map(doldur).join(' ');

  // ---- Öne çıkan alan: gökyüzü → kişilik → (gün aşırı) sahne → eylem ----
  final KategoriTonu parlayanTon = KategoriTonu.tonuBul(
    sonuc.kategoriSkorlari[parlayan] ?? 0,
  );
  // Paragraf günün Ay burcundan kurulur.
  final _GokyuzuParcalari parlayanGokyuzu = _gokyuzuParcalari(
    motor: motor,
    utcFarkiDakika: sonuc.utcFarkiDakika,
    okuyucu: okuyucu,
    gun: gun,
    kategori: parlayan,
    ton: parlayanTon,
    doldur: doldur,
    suz: (List<String> h) =>
        begenilenleriSec(h, OkumaBolumTuru.parlayan, begenilmeyenler),
  );
  final String parlayanEylem = _sec(
    motor,
    okuyucu,
    gun,
    ContentConfig.kategoriAmaci(parlayan, ContentConfig.amacEylem),
    KisiselHavuzlar.eylemCumleleri[parlayan]!,
  );
  final String parlayanMetni = <String>[
    // Ay burcu açılış paragrafında anıldı; burada yalnızca cümlenin
    // bu alana dair kısmı kalır (bkz. [ayOnekisizHali]).
    ?ayOnekisizHali(parlayanGokyuzu.gokyuzu),
    parlayanGokyuzu.kisilik,
    // Sahne günlük kartta gün aşırı yer alır: öne çıkan kategori
    // ayda 20 güne kadar aynı kalabildiği için her gün gösterilen
    // sahneler kısa sürede ezber olurdu. Detay sayfası her gün
    // gösterir.
    if (LuckEngine.gunNumarasi(gun) % ContentConfig.sahneDonusumu == 0)
      parlayanGokyuzu.sahne,
    doldur(parlayanEylem),
  ].join(' ');

  // ---- Dikkat: zayıf alanın gökyüzü cümlesi → kişinin o alandaki
  // eğilimi ("neden sende böyle hissedilir") → bir "yapma" önerisi ----
  final LuckCategory zayif = enZayifKategori(
    sonuc.kategoriSkorlari,
    haric: parlayan,
  );
  final KategoriTonu zayifTon = KategoriTonu.tonuBul(
    sonuc.kategoriSkorlari[zayif] ?? 0,
  );
  final String dikkatVaryanti;
  final String dikkatMetni;
  if (zayifTon == KategoriTonu.yuksek) {
    dikkatVaryanti = _sec(
      motor,
      okuyucu,
      gun,
      ContentConfig.amacDikkat,
      begenilenleriSec(
        KisiselHavuzlar.golgesizGun,
        OkumaBolumTuru.dikkat,
        begenilmeyenler,
      ),
    );
    dikkatMetni = dikkatVaryanti;
  } else {
    // Dikkat paragrafı: günün gökyüzü cümlesi + bir "yapma" önerisi.
    final _GokyuzuParcalari parca = _gokyuzuParcalari(
      motor: motor,
      utcFarkiDakika: sonuc.utcFarkiDakika,
      okuyucu: okuyucu,
      gun: gun,
      kategori: zayif,
      ton: zayifTon,
      doldur: doldur,
      suz: (List<String> h) =>
          begenilenleriSec(h, OkumaBolumTuru.dikkat, begenilmeyenler),
    );
    dikkatVaryanti = parca.gokyuzuSablonu;
    dikkatMetni = <String>[
      ?ayOnekisizHali(parca.gokyuzu),
      parca.kisilik,
      parca.yapma.first,
    ].join(' ');
  }

  // ---- Kapanış (dönem + ay cümlesi), tavsiye, renk, sayı ----
  final String donem = _sec(
    motor,
    okuyucu,
    gun,
    '${ContentConfig.amacYil}:${dongu.kisiselYil}:${dongu.kisiselAy}',
    YorumYonu.kapanisHavuzu(dongu.kisiselYil, dongu.kisiselAy),
  );
  // Günün tavsiyesi doğum verisinden gelir (KARARLAR 2026-11-26, soru 3):
  // genel havuza burç elementinin enerjisine (içe / dışa dönük) özgü
  // öneriler eklenir. Anahtardaki enerji adı iki portrenin seçimini
  // birbirinden ayırır.
  final EnerjiTarzi enerji = okuyucu.portre.enerji;
  final String tavsiye = doldur(
    _sec(
      motor,
      okuyucu,
      gun,
      '${ContentConfig.amacTavsiye}:${enerji.name}',
      <String>[
        ...FortunePools.gununTavsiyeleri,
        ...KisiselHavuzlar.enerjiTavsiyeleri[enerji]!,
      ],
    ),
  );
  final SansRengi renk = _sec(
    motor,
    okuyucu,
    gun,
    ContentConfig.amacRenk,
    FortunePools.sansRenkleri,
  );
  final int sansliSayi =
      ContentConfig.sansliSayiMin +
      motor.secimIndeksi(
        kullanici: okuyucu.seed,
        gun: gun,
        amac: ContentConfig.amacSayi,
        havuzBoyutu:
            ContentConfig.sansliSayiMaks - ContentConfig.sansliSayiMin + 1,
      );

  return GunlukOkuma(
    baslik: baslik,
    dongu: dongu,
    bolumler: <OkumaBolumu>[
      OkumaBolumu(
        tur: OkumaBolumTuru.enerji,
        kimlik: bolumKimligi(OkumaBolumTuru.enerji, gunDurumu),
        metin: enerjiMetni,
      ),
      OkumaBolumu(
        tur: OkumaBolumTuru.parlayan,
        kimlik: bolumKimligi(
          OkumaBolumTuru.parlayan,
          parlayanGokyuzu.gokyuzuSablonu,
        ),
        metin: parlayanMetni,
        kategori: parlayan,
      ),
      OkumaBolumu(
        tur: OkumaBolumTuru.dikkat,
        kimlik: bolumKimligi(OkumaBolumTuru.dikkat, dikkatVaryanti),
        metin: dikkatMetni,
        kategori: zayif,
      ),
    ],
    kapanis: donem,
    cunku: NedenMetinleri.cunku(
      dogumTarihi: okuyucu.profil.dogumTarihi,
      gunesBurcu: okuyucu.profil.burc,
      ayBurcu: ayBurcu,
      dogumAyi: okuyucu.dogumAyi,
      yukselen: okuyucu.yukselen,
    ),
    nedenler: nedenOgeleri(
      sonuc: sonuc,
      dongu: dongu,
      cakisma: k == okuyucu.profil.yasamYolu.taban,
      bulusma: bulusma,
      gunesBurcu: okuyucu.profil.burc,
    ),
    sansRengi: renk,
    sansliSayi: sansliSayi,
    tavsiye: tavsiye,
    parlayanKategori: parlayan,
    dikkatKategori: zayif,
    sansliSaat: saat,
  );
}

/// "Neden bugün?" öğelerini üretir: kişisel gün (ve varsa sayıyla
/// çakışma), Ay'ın günlük burcu, Ay evresi ve günün sayısı.
///
/// Öğeler yalnızca anlamı anlatır; puan etkileri ve hesaplama yöntemi
/// gösterilmez. Düşük seriyi telafi eden denge etkisi skora uygulanır ama
/// kullanıcıya bir neden olarak sunulmaz.
List<NedenOgesi> nedenOgeleri({
  required LuckResult sonuc,
  required GunDongusu dongu,
  required bool cakisma,
  required BulusmaTuru bulusma,
  required Burc gunesBurcu,
}) {
  final Burc ayBurcu = Astronomi.gununAyBurcu(
    sonuc.gun,
    utcFarkiDakika: sonuc.utcFarkiDakika,
  );
  final List<NedenOgesi> ogeler = <NedenOgesi>[
    NedenOgesi(
      tur: NedenTuru.kisiselGun,
      etiket: NedenMetinleri.kisiselGunEtiketi(dongu.kisiselGun),
      aciklama: NedenMetinleri.kisiselGunAciklamasi(dongu, bulusma),
    ),
    if (cakisma)
      NedenOgesi(
        tur: NedenTuru.cakisma,
        etiket: NedenMetinleri.cakismaEtiketi,
        aciklama: NedenMetinleri.cakismaAciklamasi,
      ),
    NedenOgesi(
      tur: NedenTuru.ayBurcu,
      etiket: NedenMetinleri.ayBurcuEtiketi(ayBurcu),
      aciklama: NedenMetinleri.ayBurcuAciklamasi(ayBurcu, gunesBurcu),
    ),
  ];
  for (final LuckModifier m in sonuc.modifiyerler) {
    switch (m.ad) {
      case ayEvresiAdi:
        ogeler.add(
          NedenOgesi(
            tur: NedenTuru.ayEvresi,
            etiket: NedenMetinleri.ayEvresiEtiketi(dongu.ayEvresi),
            aciklama: NedenMetinleri.ayEvresiAciklamasi(dongu.ayEvresi),
          ),
        );
      case numerolojiAdi:
        final int gunSayisi = gunNumerolojiSayisi(sonuc.gun);
        ogeler.add(
          NedenOgesi(
            tur: NedenTuru.gunSayisi,
            etiket: NedenMetinleri.gunSayisiEtiketi(gunSayisi),
            aciklama: NedenMetinleri.gunSayisiAciklamasi(gunSayisi),
          ),
        );
    }
  }
  return ogeler;
}

/// [kategori] detay sayfasının okumasını üretir.
///
/// Başlık + paragraf (günün Ay burcu × kişinin burcu × ton, kişilik
/// cümlesi, gündelik sahne) + "Yap / Yapma" önerileri (bkz.
/// `gokyuzu_metinleri.dart`). [paket]: içerik dili.
KategoriOkumasi kategoriOkumasi({
  required LuckEngine motor,
  required Okuyucu okuyucu,
  required LuckResult sonuc,
  required LuckCategory kategori,
  IcerikPaketi paket = trIcerik,
}) {
  final DateTime gun = sonuc.gun;
  final int skor = sonuc.kategoriSkorlari[kategori] ?? 0;
  final KategoriTonu ton = KategoriTonu.tonuBul(skor);
  final GunDongusu dongu = GunDongusu.hesapla(
    dogumTarihi: okuyucu.profil.dogumTarihi,
    gun: gun,
    utcFarkiDakika: sonuc.utcFarkiDakika,
  );
  final SansliSaat saat = motor.sansliSaat(
    kullanici: okuyucu.seed,
    gun: gun,
    kategori: kategori,
  );
  final Map<String, String> slotlar = slotSozlugu(
    okuyucu,
    gun: gun,
    dongu: dongu,
    saat: saat,
    ayBurcu: Astronomi.gununAyBurcu(gun, utcFarkiDakika: sonuc.utcFarkiDakika),
    paket: paket,
  );
  String doldur(String s) => slotDoldur(s, slotlar);

  final String eylem = doldur(
    _sec(
      motor,
      okuyucu,
      gun,
      '${ContentConfig.kategoriAmaci(kategori, ContentConfig.amacEylem)}:${ContentConfig.amacDetayEki}',
      KisiselHavuzlar.eylemCumleleri[kategori]!,
    ),
  );

  final _GokyuzuParcalari parca = _gokyuzuParcalari(
    motor: motor,
    utcFarkiDakika: sonuc.utcFarkiDakika,
    okuyucu: okuyucu,
    gun: gun,
    kategori: kategori,
    ton: ton,
    doldur: doldur,
    ek: ContentConfig.amacDetayEki,
  );
  return KategoriOkumasi(
    kategori: kategori,
    skor: skor,
    ton: ton,
    paragraf: '${parca.gokyuzu} ${parca.kisilik} ${parca.sahne}',
    eylem: eylem,
    sansliSaat: saat,
    baslik: parca.baslik,
    yap: parca.yap,
    yapma: parca.yapma,
  );
}

/// [okuyucu]nun Kader Profili bölümlerini üretir (ekran sırasıyla).
///
/// Tam ad yoksa isim tabanlı bölümler (iç ses, yansıma) listede yer
/// almaz. Profil metinleri gün değişse de aynı kalır; yalnızca yıl
/// bölümü takvim yılına bağlıdır. [paket]: içerik dili.
List<ProfilBolumu> profilOkumasi({
  required Okuyucu okuyucu,
  required DateTime gun,
  IcerikPaketi paket = trIcerik,
}) {
  final KaderProfili p = okuyucu.profil;
  final SayiKarakteri karakter = SayiMetinleri.yasamYolu[p.yasamYolu.deger]!;
  final int kisiselYil = Numeroloji.kisiselYil(p.dogumTarihi, gun.year);
  final KisiselYilMetni yil = DonguMetinleri.kisiselYil[kisiselYil]!;
  final Map<String, String> slotlar = slotSozlugu(
    okuyucu,
    gun: gun,
    paket: paket,
  );
  String doldur(String s) => slotDoldur(s, slotlar);
  // Yaşam yolu metinlerinde portreyle çelişen cümleler uyarlanır (ör.
  // insanlarla beslenen birine "asıl yenilenmen yalnız kaldığında olur"
  // denmez).
  String uyarla(String metin) =>
      KisilikMetinleri.profilMetniniUyarla(metin, okuyucu.portre);

  return <ProfilBolumu>[
    ProfilBolumu(
      tur: ProfilBolumTuru.oz,
      baslik: 'Özün · ${karakter.lakap}',
      metin: doldur(uyarla(karakter.oz)),
      premium: false,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.gucluYanlar,
      baslik: 'Güçlü yanların',
      metin: doldur(uyarla(karakter.gucluYanlar)),
      premium: false,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.burc,
      baslik:
          '${paket.burcAdi(p.burc)} burcu · '
          '${paket.elementAdi(p.burc.element)}',
      metin: <String>[
        BurcMetinleri.oz[p.burc]!,
        if (p.burcSinirGunu) BurcMetinleri.sinirNotu,
      ].join(' '),
      premium: false,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.golgeYan,
      baslik: 'Gölge yanın',
      metin: doldur(uyarla(karakter.golgeYan)),
      premium: true,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.askta,
      baslik: 'Aşkta',
      metin: doldur(uyarla(karakter.askta)),
      premium: true,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.isteVeParada,
      baslik: 'İşte ve parada',
      metin: doldur(uyarla(karakter.isteVeParada)),
      premium: true,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.yasamDersi,
      baslik: 'Yaşam dersin',
      metin: doldur(uyarla(karakter.yasamDersi)),
      premium: true,
    ),
    if (p.ruhSayisi != null)
      ProfilBolumu(
        tur: ProfilBolumTuru.icSes,
        baslik: 'İç sesin · Ruh sayısı ${p.ruhSayisi!.deger}',
        metin: SayiMetinleri.ruhSayisi[p.ruhSayisi!.deger]!,
        premium: true,
      ),
    if (p.isimSayisi != null)
      ProfilBolumu(
        tur: ProfilBolumTuru.yansima,
        baslik: 'Dünyaya yansıman · İsim sayısı ${p.isimSayisi!.deger}',
        metin: <String>[
          SayiMetinleri.isimSayisi[p.isimSayisi!.deger]!,
          if (p.kisilikSayisi != null)
            SayiMetinleri.kisilikSayisi[p.kisilikSayisi!.deger]!,
        ].join(' '),
        premium: true,
      ),
    ProfilBolumu(
      tur: ProfilBolumTuru.yil,
      baslik: '${gun.year} · ${yil.baslik}',
      metin: doldur(yil.uzun),
      premium: true,
    ),
  ];
}

/// [okuyucu] ile [digerIsim]/[digerProfil] arasındaki uyum okuması.
/// [paket]: içerik dili.
UyumOkumasi uyumOkumasi({
  required Okuyucu okuyucu,
  required String digerIsim,
  required KaderProfili digerProfil,
  IcerikPaketi paket = trIcerik,
}) {
  final UyumSonucu sonuc = uyumHesapla(okuyucu.profil, digerProfil);
  final Map<String, String> slotlar = slotSozlugu(
    okuyucu,
    digerIsim: digerIsim,
    paket: paket,
  );
  String doldur(String s) => slotDoldur(s, slotlar);
  // Varyant, çifte özgü skordan seçilir: simetrik ve deterministik.
  T sec<T>(List<T> havuz) => havuz[sonuc.skor % havuz.length];

  final SayiKarakteri ben =
      SayiMetinleri.yasamYolu[okuyucu.profil.yasamYolu.deger]!;
  final SayiKarakteri o = SayiMetinleri.yasamYolu[digerProfil.yasamYolu.deger]!;

  return UyumOkumasi(
    sonuc: sonuc,
    bolumler: <UyumBolumu>[
      UyumBolumu(
        baslik:
            '${okuyucu.isim} · Yaşam yolu ${okuyucu.profil.yasamYolu.deger} '
            '(${ben.lakap})',
        metin: ben.iliskide,
      ),
      UyumBolumu(
        baslik:
            '$digerIsim · Yaşam yolu ${digerProfil.yasamYolu.deger} '
            '(${o.lakap})',
        metin: o.iliskide,
      ),
      UyumBolumu(
        baslik: 'Birlikte',
        metin: doldur(sec(UyumMetinleri.yasamYolu[sonuc.yasamYoluIliskisi]!)),
      ),
      UyumBolumu(
        baslik:
            '${paket.burcAdi(okuyucu.profil.burc)} & '
            '${paket.burcAdi(digerProfil.burc)}',
        metin: UyumMetinleri.element[sonuc.elementIliskisi]!,
      ),
      if (sonuc.ruhUyumlu != null)
        UyumBolumu(
          baslik: 'Ruh bağı',
          metin: UyumMetinleri.ruh[sonuc.ruhUyumlu!]!,
        ),
      UyumBolumu(
        baslik: 'Tavsiye',
        metin: sec(UyumMetinleri.tavsiye[sonuc.derece]!),
      ),
    ],
  );
}
