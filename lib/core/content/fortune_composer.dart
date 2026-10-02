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
import 'gunluk_okuma.dart';
import 'kisisel_havuzlar.dart';
import 'neden_metinleri.dart';
import 'okuyucu.dart';
import 'sans_rengi.dart';
import 'sayi_metinleri.dart';
import 'slot_doldurucu.dart';
import 'turkce_ek.dart';
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
Map<String, String> slotSozlugu(
  Okuyucu okuyucu, {
  DateTime? gun,
  GunDongusu? dongu,
  SansliSaat? saat,
  String? digerIsim,
}) {
  final KarakterYonu? karakter =
      YorumYonu.karakterler[okuyucu.profil.yasamYolu.deger];
  return <String, String>{
    SlotAnahtarlari.isim: okuyucu.isim,
    SlotAnahtarlari.isimIlgi: TurkceEk.ilgi(okuyucu.isim),
    SlotAnahtarlari.burc: okuyucu.profil.burc.etiket,
    SlotAnahtarlari.yasamYolu: '${okuyucu.profil.yasamYolu.deger}',
    SlotAnahtarlari.ugrasAlani:
        okuyucu.tercihler.ugras?.alan ?? KisiselHavuzlar.varsayilanUgrasAlani,
    if (karakter != null) SlotAnahtarlari.doga: karakter.doga,
    if (dongu != null) SlotAnahtarlari.kisiselGun: '${dongu.kisiselGun}',
    if (dongu != null) SlotAnahtarlari.kisiselYil: '${dongu.kisiselYil}',
    if (dongu != null)
      SlotAnahtarlari.gunIstegi: YorumYonu.gunTemalari[dongu.kisiselGun]!.istek,
    if (gun != null) SlotAnahtarlari.yil: '${gun.year}',
    if (saat != null) SlotAnahtarlari.saat: saat.etiket,
    if (digerIsim != null) SlotAnahtarlari.digerIsim: digerIsim,
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

/// [okuyucu] için [sonuc] gününün tam, bölümlü okumasını üretir.
///
/// [begenilmeyenler]: kullanıcının BU GÜNDEN ÖNCE "beni anlatmadı" dediği
/// bölüm kimlikleri (bkz. [bolumKimligi]).
GunlukOkuma gunlukOkuma({
  required LuckEngine motor,
  required Okuyucu okuyucu,
  required LuckResult sonuc,
  Set<String> begenilmeyenler = const <String>{},
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
  final List<String> oneriler = karakter.tavsiyeler(bulusma);
  final int oneriTabani = motor.donguselIndeks(
    kullanici: okuyucu.seed,
    gun: gun,
    amac: '${ContentConfig.amacOneri}:${bulusma.name}',
    havuzBoyutu: oneriler.length,
    adimGun: ContentConfig.kisiselGunAdimi,
  );
  final String oneri = oneriler[(oneriTabani + k) % oneriler.length];
  final String enerjiMetni = <String>[
    gunDurumu,
    bulusmaCumlesi,
    sahne,
    oneri,
  ].map(doldur).join(' ');

  // ---- Öne çıkan alan: durum → günün etkisi → kişinin tarzı → eylem ----
  final KategoriTonu parlayanTon = KategoriTonu.tonuBul(
    sonuc.kategoriSkorlari[parlayan] ?? 0,
  );
  final String parlayanDurum = _sec(
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
  final String parlayanMetni = <String>[
    parlayanDurum,
    YorumYonu.temaKategori[k]![parlayan]!,
    if (tarzParlayanda) _tarz(motor, okuyucu, gun, parlayan),
    _sec(
      motor,
      okuyucu,
      gun,
      ContentConfig.kategoriAmaci(parlayan, ContentConfig.amacEylem),
      KisiselHavuzlar.eylemCumleleri[parlayan]!,
    ),
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
    ),
    sansRengi: renk,
    sansliSayi: sansliSayi,
    tavsiye: tavsiye,
    parlayanKategori: parlayan,
    dikkatKategori: zayif,
    sansliSaat: saat,
  );
}

/// "Neden bugün?" öğelerini motor modifiyerleri ve döngülerden kurar.
List<NedenOgesi> nedenOgeleri({
  required LuckResult sonuc,
  required GunDongusu dongu,
  required bool cakisma,
  required BulusmaTuru bulusma,
}) {
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
  ];
  for (final LuckModifier m in sonuc.modifiyerler) {
    switch (m.ad) {
      case ayEvresiAdi:
        ogeler.add(
          NedenOgesi(
            tur: NedenTuru.ayEvresi,
            etiket: NedenMetinleri.ayEvresiEtiketi(dongu.ayEvresi, m.etki),
            aciklama: NedenMetinleri.ayEvresiAciklamasi(dongu.ayEvresi, m.etki),
            etki: m.etki,
          ),
        );
      case numerolojiAdi:
        final int gunSayisi = gunNumerolojiSayisi(sonuc.gun);
        ogeler.add(
          NedenOgesi(
            tur: NedenTuru.gunSayisi,
            etiket: NedenMetinleri.gunSayisiEtiketi(gunSayisi, m.etki),
            aciklama: NedenMetinleri.gunSayisiAciklamasi(
              sonuc.gun,
              gunSayisi,
              m.etki,
            ),
            etki: m.etki,
          ),
        );
      case seriDengesiAdi:
        ogeler.add(
          NedenOgesi(
            tur: NedenTuru.seriDengesi,
            etiket: NedenMetinleri.seriEtiketi(m.etki),
            aciklama: NedenMetinleri.seriAciklamasi(m.etki),
            etki: m.etki,
          ),
        );
    }
  }
  return ogeler;
}

/// [kategori] detay sayfasının okumasını üretir.
///
/// Paragraf: bugünün o alandaki durumu (kişinin durumuna göre; düşük
/// günlerde uyarıyı da içerir) + günün temasının o alana etkisi + kişinin
/// o alandaki tarzı + somut tavsiye.
KategoriOkumasi kategoriOkumasi({
  required LuckEngine motor,
  required Okuyucu okuyucu,
  required LuckResult sonuc,
  required LuckCategory kategori,
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
  );
  String doldur(String s) => slotDoldur(s, slotlar);

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

  final String eylem = doldur(
    _sec(
      motor,
      okuyucu,
      gun,
      '${ContentConfig.kategoriAmaci(kategori, ContentConfig.amacEylem)}:${ContentConfig.amacDetayEki}',
      KisiselHavuzlar.eylemCumleleri[kategori]!,
    ),
  );

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
/// bölümü takvim yılına bağlıdır.
List<ProfilBolumu> profilOkumasi({
  required Okuyucu okuyucu,
  required DateTime gun,
}) {
  final KaderProfili p = okuyucu.profil;
  final SayiKarakteri karakter = SayiMetinleri.yasamYolu[p.yasamYolu.deger]!;
  final int kisiselYil = Numeroloji.kisiselYil(p.dogumTarihi, gun.year);
  final KisiselYilMetni yil = DonguMetinleri.kisiselYil[kisiselYil]!;
  final Map<String, String> slotlar = slotSozlugu(okuyucu, gun: gun);
  String doldur(String s) => slotDoldur(s, slotlar);
  final IliskiDurumu? iliski = okuyucu.tercihler.iliski;
  final Ugras? ugras = okuyucu.tercihler.ugras;

  return <ProfilBolumu>[
    ProfilBolumu(
      tur: ProfilBolumTuru.oz,
      baslik: 'Özün · ${karakter.lakap}',
      metin: doldur(karakter.oz),
      premium: false,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.gucluYanlar,
      baslik: 'Güçlü yanların',
      metin: doldur(karakter.gucluYanlar),
      premium: false,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.burc,
      baslik: '${p.burc.etiket} burcu · ${p.burc.element.etiket}',
      metin: <String>[
        BurcMetinleri.oz[p.burc]!,
        if (p.burcSinirGunu) BurcMetinleri.sinirNotu,
      ].join(' '),
      premium: false,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.golgeYan,
      baslik: 'Gölge yanın',
      metin: doldur(karakter.golgeYan),
      premium: true,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.askta,
      baslik: 'Aşkta',
      metin: <String>[
        karakter.askta,
        if (iliski != null)
          KisiselHavuzlar.profilIliskiEki[iliski.partnerliMi]!,
      ].map(doldur).join(' '),
      premium: true,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.isteVeParada,
      baslik: 'İşte ve parada',
      metin: <String>[
        karakter.isteVeParada,
        if (ugras != null) KisiselHavuzlar.profilUgrasEki[ugras]!,
      ].map(doldur).join(' '),
      premium: true,
    ),
    ProfilBolumu(
      tur: ProfilBolumTuru.yasamDersi,
      baslik: 'Yaşam dersin',
      metin: doldur(karakter.yasamDersi),
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
UyumOkumasi uyumOkumasi({
  required Okuyucu okuyucu,
  required String digerIsim,
  required KaderProfili digerProfil,
}) {
  final UyumSonucu sonuc = uyumHesapla(okuyucu.profil, digerProfil);
  final Map<String, String> slotlar = slotSozlugu(
    okuyucu,
    digerIsim: digerIsim,
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
        baslik: '${okuyucu.profil.burc.etiket} & ${digerProfil.burc.etiket}',
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
