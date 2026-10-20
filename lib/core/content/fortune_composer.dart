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
import 'category_pools.dart';
import 'content_config.dart';
import 'dongu_metinleri.dart';
import 'fortune_pools.dart';
import 'gokyuzu_metinleri.dart';
import 'gunluk_okuma.dart';
import 'icerik_paketi.dart';
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
    SlotAnahtarlari.ugrasAlani: paket.ugrasAlani(okuyucu.tercihler.ugras),
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

/// Havuzdan deterministik ve döngü içinde tekrarsız eleman seçer.
T _sec<T>(
  LuckEngine motor,
  Okuyucu okuyucu,
  DateTime gun,
  String amac,
  List<T> havuz, {
  int adimGun = 1,
}) {
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

/// [okuyucu]nun [kategori] alanındaki tarz cümlesi.
///
/// Tarz varyantları kategori başına döngüsel seçilir; [ek] verilirse
/// (ör. detay sayfası) ayrı bir döngü kullanılır ki aynı gün kart ile
/// detay aynı cümleyi göstermesin.
String _tarz(
  LuckEngine motor,
  Okuyucu okuyucu,
  DateTime gun,
  LuckCategory kategori, {
  String? ek,
}) {
  final String amac = ContentConfig.kategoriAmaci(
    kategori,
    ContentConfig.amacTarz,
  );
  return _sec(
    motor,
    okuyucu,
    gun,
    ek == null ? amac : '$amac:$ek',
    _karakter(okuyucu).kategoriTarzi[kategori]!,
  );
}

/// [kategori] alanında bugünün durum cümlesi varyantları.
List<String> _durumHavuzu(
  Okuyucu okuyucu,
  LuckCategory kategori,
  KategoriTonu ton,
) =>
    YorumYonu.kategoriDurumlari[kategori]![YorumYonu.durumAnahtari(
      kategori,
      okuyucu.tercihler,
    )]![ton]!;

/// Gökyüzü tabanlı bir kategori okumasının doldurulmuş parçaları (bkz.
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
}) {
  final Burc ayBurcu = Astronomi.gununAyBurcu(gun);
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

  final List<String> gokyuzuHavuzu =
      GokyuzuMetinleri.gokyuzu[kategori]![iliski]![ton]!;
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
      if (!KisilikMetinleri.celisir(m, okuyucu.tercihler)) m,
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
      ? KisilikMetinleri.uyumlular(
          KisilikMetinleri.burc[okuyucu.profil.burc]![kategori]!,
          okuyucu.tercihler,
        )
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

  final Map<String, Map<SahneYonu, List<String>>> sahneler =
      GokyuzuMetinleri.sahneler[kategori]!;
  final String sahneAnahtari = GokyuzuMetinleri.sahneAnahtari(
    kategori,
    okuyucu.tercihler,
  );
  final SahneYonu yon = SahneYonu.tondan(ton);
  final List<String> sahneHavuzu =
      (sahneler[sahneAnahtari] ??
      sahneler[GokyuzuMetinleri.genelAnahtar]!)[yon]!;
  final String sahne = sec(
    sahneHavuzu,
    ContentConfig.amacKategoriSahne,
    '$sahneAnahtari:${yon.name}',
  );

  final String baslik = sec(
    GokyuzuMetinleri.basliklar[kategori]![ton]!,
    ContentConfig.amacKategoriBaslik,
    ton.name,
  );

  // Yap: kişinin doğasına uygun bir öneri (varsa) + genel öneriler.
  final String? kisiselAnahtar = GokyuzuMetinleri.kisiselAnahtar(
    kategori,
    okuyucu.tercihler,
  );
  final List<String>? kisiselHavuz = kisiselAnahtar == null
      ? null
      : GokyuzuMetinleri.kisiselYap[kategori]?[kisiselAnahtar]?[ton];
  final String? kisiselYap = kisiselHavuz == null
      ? null
      : sec(
          kisiselHavuz,
          ContentConfig.amacKisiselYap,
          '$kisiselAnahtar:${ton.name}',
        );
  final List<String> genelYap = GokyuzuMetinleri.yap[kategori]![ton]!;
  final List<String> yap = <String>[
    ?kisiselYap,
    ...ardisik(
      genelYap,
      sec(genelYap, ContentConfig.amacYap, ton.name),
      ContentConfig.gokyuzuYapSayisi - (kisiselYap == null ? 0 : 1),
    ),
  ];
  final List<String> yapmaHavuzu = GokyuzuMetinleri.yapma[kategori]![ton]!;
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
    ayBurcu: Astronomi.gununAyBurcu(gun),
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
    begenilenleriSec(
      YorumYonu.gunTemalari[k]!.durum[gunTonu]!,
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
  final Map<String, List<String>> sahneler = YorumYonu.gunSahneleri[k]!;
  final String sahne = _sec(
    motor,
    okuyucu,
    gun,
    '${ContentConfig.amacSahne}:$k',
    sahneler[okuyucu.tercihler.ugras?.name] ??
        sahneler[YorumYonu.genelAnahtar]!,
    adimGun: ContentConfig.kisiselGunAdimi,
  );
  // Öneri: buluşma türü ayın belirli kişisel günlerine denk geldiği için
  // takvim günüyle dönen bir seçim aynı varyantı aynı günlere tekrar
  // tekrar düşürür. Taban indeks kişisel gün adımıyla (~9 gün) döner,
  // kişisel gün de ötelemeye eklenir: ardışık günler (k, k+1) farklı
  // varyant alır, aynı kişisel gün sonraki dönemde başka varyant görür.
  // Öneriler de okuyucunun cevaplarıyla çelişmeyenler arasından seçilir
  // (ör. insanlarla beslenen birine "yalnız kalma ihtiyacını koru" denmez).
  final List<String> oneriler = KisilikMetinleri.uyumlular(
    karakter.tavsiyeler(bulusma),
    okuyucu.tercihler,
  );
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
  final Burc ayBurcu = Astronomi.gununAyBurcu(gun);
  final ElementIliskisi gunIliskisi = elementIliskisi(
    ayBurcu.element,
    okuyucu.profil.burc.element,
  );
  final List<String> gunGokyuzuHavuzu =
      GokyuzuMetinleri.gunler[gunIliskisi]![gunTonu]!;
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
  // gündelik sahne gün aşırı dönüşümlü yer alır.
  final bool bulusmaGunu =
      LuckEngine.gunNumarasi(gun) % ContentConfig.bulusmaDonusumu == 0;
  final String enerjiMetni = <String>[
    gunDurumu,
    gunGokyuzu,
    if (bulusmaGunu) bulusmaCumlesi else sahne,
    oneri,
  ].map(doldur).join(' ');

  // ---- Öne çıkan alan: durum → günün etkisi → kişinin tarzı → eylem ----
  final KategoriTonu parlayanTon = KategoriTonu.tonuBul(
    sonuc.kategoriSkorlari[parlayan] ?? 0,
  );
  // Gökyüzü tabanlı kategorilerde (Sağlık, Risk, Sosyal) paragraf günün
  // Ay burcundan kurulur; diğerlerinde durum + tema + tarz yapısı sürer.
  final _GokyuzuParcalari? parlayanGokyuzu =
      GokyuzuMetinleri.destekler(parlayan)
      ? _gokyuzuParcalari(
          motor: motor,
          okuyucu: okuyucu,
          gun: gun,
          kategori: parlayan,
          ton: parlayanTon,
          doldur: doldur,
          suz: (List<String> h) =>
              begenilenleriSec(h, OkumaBolumTuru.parlayan, begenilmeyenler),
        )
      : null;
  final String parlayanDurum =
      parlayanGokyuzu?.gokyuzuSablonu ??
      _sec(
        motor,
        okuyucu,
        gun,
        ContentConfig.kategoriAmaci(parlayan, ContentConfig.amacOrta),
        begenilenleriSec(
          _durumHavuzu(okuyucu, parlayan, parlayanTon),
          OkumaBolumTuru.parlayan,
          begenilmeyenler,
        ),
      );
  // Kişinin tarz cümlesi günde yalnızca bir paragrafta yer alır; hangisine
  // düşeceği takvim gününe göre dönüşümlüdür. İki paragrafta birden yer
  // aldığında neredeyse her gün öne çıkan bir kategorinin tarzı ayda
  // 7-8 kez tekrar ediyordu.
  final bool tarzParlayanda =
      LuckEngine.gunNumarasi(gun) % ContentConfig.tarzDonusumu == 0;
  final String parlayanEylem = _sec(
    motor,
    okuyucu,
    gun,
    ContentConfig.kategoriAmaci(parlayan, ContentConfig.amacEylem),
    KisiselHavuzlar.eylemCumleleri[parlayan]!,
  );
  final String parlayanMetni = parlayanGokyuzu != null
      ? <String>[
          parlayanGokyuzu.gokyuzu,
          parlayanGokyuzu.kisilik,
          // Sahne günlük kartta gün aşırı yer alır: öne çıkan kategori
          // ayda 20 güne kadar aynı kalabildiği için her gün gösterilen
          // sahneler kısa sürede ezber olurdu. Detay sayfası her gün
          // gösterir.
          if (LuckEngine.gunNumarasi(gun) % ContentConfig.sahneDonusumu == 0)
            parlayanGokyuzu.sahne,
          doldur(parlayanEylem),
        ].join(' ')
      : <String>[
          parlayanDurum,
          YorumYonu.temaKategori[k]![parlayan]!,
          if (tarzParlayanda) _tarz(motor, okuyucu, gun, parlayan),
          parlayanEylem,
        ].map(doldur).join(' ');

  // ---- Dikkat: zayıf alanın durumu (öneriyi zaten içerir) → kişinin
  // o alandaki eğilimi ("neden sende böyle hissedilir") ----
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
  } else if (GokyuzuMetinleri.destekler(zayif)) {
    // Dikkat paragrafı: günün gökyüzü cümlesi + bir "yapma" önerisi.
    final _GokyuzuParcalari parca = _gokyuzuParcalari(
      motor: motor,
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
      parca.gokyuzu,
      parca.kisilik,
      parca.yapma.first,
    ].join(' ');
  } else {
    dikkatVaryanti = _sec(
      motor,
      okuyucu,
      gun,
      ContentConfig.kategoriAmaci(zayif, ContentConfig.amacDurum),
      begenilenleriSec(
        _durumHavuzu(okuyucu, zayif, zayifTon),
        OkumaBolumTuru.dikkat,
        begenilmeyenler,
      ),
    );
    dikkatMetni = <String>[
      dikkatVaryanti,
      if (!tarzParlayanda) _tarz(motor, okuyucu, gun, zayif),
    ].map(doldur).join(' ');
  }

  // ---- Kapanış (dönem + ay cümlesi), tavsiye, renk, sayı ----
  final String donem = _sec(
    motor,
    okuyucu,
    gun,
    '${ContentConfig.amacYil}:${dongu.kisiselYil}:${dongu.kisiselAy}',
    YorumYonu.kapanisHavuzu(dongu.kisiselYil, dongu.kisiselAy),
  );
  final EnerjiTarzi? enerjiTarzi = okuyucu.tercihler.enerji;
  final String tavsiye = doldur(
    _sec(
      motor,
      okuyucu,
      gun,
      '${ContentConfig.amacTavsiye}:${enerjiTarzi?.name ?? '-'}',
      <String>[
        ...FortunePools.gununTavsiyeleri,
        if (enerjiTarzi != null)
          ...KisiselHavuzlar.enerjiTavsiyeleri[enerjiTarzi]!,
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
        kimlik: bolumKimligi(OkumaBolumTuru.parlayan, parlayanDurum),
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
  final Burc ayBurcu = Astronomi.gununAyBurcu(sonuc.gun);
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
/// Gökyüzü tabanlı kategorilerde (bkz. [GokyuzuMetinleri.kategoriler])
/// başlık + paragraf (günün Ay burcu × kişinin burcu × ton, kişilik
/// cümlesi, gündelik sahne) + "Yap / Yapma" önerileri. Diğerlerinde paragraf:
/// bugünün o alandaki durumu + günün temasının o alana etkisi + kişinin
/// o alandaki tarzı + somut tavsiye. [paket]: içerik dili.
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
    ayBurcu: Astronomi.gununAyBurcu(gun),
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

  if (GokyuzuMetinleri.destekler(kategori)) {
    final _GokyuzuParcalari parca = _gokyuzuParcalari(
      motor: motor,
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

  final String paragraf = <String>[
    _sec(
      motor,
      okuyucu,
      gun,
      '${ContentConfig.kategoriAmaci(kategori, ContentConfig.amacDurum)}:${ContentConfig.amacDetayEki}',
      _durumHavuzu(okuyucu, kategori, ton),
    ),
    YorumYonu.temaKategori[dongu.kisiselGun]![kategori]!,
    _tarz(motor, okuyucu, gun, kategori, ek: ContentConfig.amacDetayEki),
    _sec(
      motor,
      okuyucu,
      gun,
      ContentConfig.kategoriAmaci(kategori, ContentConfig.amacTavsiye),
      CategoryPools.kategoriTavsiyeleri[kategori]!,
    ),
  ].map(doldur).join(' ');

  return KategoriOkumasi(
    kategori: kategori,
    skor: skor,
    ton: ton,
    paragraf: paragraf,
    eylem: eylem,
    sansliSaat: saat,
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
  // Yaşam yolu metinlerinde okuyucunun cevabıyla çelişen cümleler
  // uyarlanır (ör. insanlarla beslenen birine "asıl yenilenmen yalnız
  // kaldığında olur" denmez).
  String uyarla(String metin) =>
      KisilikMetinleri.profilMetniniUyarla(metin, okuyucu.tercihler);
  final IliskiDurumu? iliski = okuyucu.tercihler.iliski;
  final Ugras? ugras = okuyucu.tercihler.ugras;

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
      metin: <String>[
        uyarla(karakter.askta),
        if (iliski != null)
          KisiselHavuzlar.profilIliskiEki[iliski.partnerliMi]!,
      ].map(doldur).join(' '),
      premium: true,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.isteVeParada,
      baslik: 'İşte ve parada',
      metin: <String>[
        uyarla(karakter.isteVeParada),
        if (ugras != null) KisiselHavuzlar.profilUgrasEki[ugras]!,
      ].map(doldur).join(' '),
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
