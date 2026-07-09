/// Günlük fal metinlerini havuzlardan deterministik biçimde birleştirir.
///
/// Kritik sözleşme: bantlar/tonlar SAKLANAN [LuckResult] skorlarından
/// okunur — genel skor "seri dengesi" bias'ı yüzünden (kullanıcı, gün)
/// çiftinden yeniden türetilemez. Varyasyon indeksleri ise motorun
/// bağımsız içerik tohumundan gelir; böylece aynı (kullanıcı, gün,
/// saklanan sonuç) her zaman aynı metni üretir (CLAUDE.md kural 8).
library;

import '../luck_engine/luck_engine.dart';
import 'category_pools.dart';
import 'content_config.dart';
import 'fortune_pools.dart';
import 'gunun_icerigi.dart';
import 'sans_rengi.dart';

/// [sonuc] ve (kullanici, sonuc.gun) tohumundan günün tam içerik
/// paketini üretir: 3 cümlelik yorum + şans rengi + şanslı sayı +
/// günün tavsiyesi.
GununIcerigi gununIcerigi({
  required LuckEngine motor,
  required UserSeed kullanici,
  required LuckResult sonuc,
}) {
  final DateTime gun = sonuc.gun;

  // Açılış: genel skorun bandından seçilir.
  final List<String> acilisHavuzu =
      FortunePools.acilisCumleleri[SkorBandi.bandiBul(sonuc.genelSkor)]!;
  final String acilis = acilisHavuzu[motor.tekrarsizSecimIndeksi(
    kullanici: kullanici,
    gun: gun,
    amac: ContentConfig.amacAcilis,
    havuzBoyutu: acilisHavuzu.length,
  )];

  // Orta: günün baskın kategorisi, o kategorinin KENDİ skoruna göre
  // tonlanır (genel banda değil; kategori hikâyesi kendi tonuyla anlatılır).
  final LuckCategory baskin = baskinKategori(sonuc.kategoriSkorlari);
  final List<String> ortaHavuzu = FortunePools.ortaCumleleri[baskin]![
      KategoriTonu.tonuBul(sonuc.kategoriSkorlari[baskin]!)]!;
  final String orta = ortaHavuzu[motor.tekrarsizSecimIndeksi(
    kullanici: kullanici,
    gun: gun,
    amac: ContentConfig.amacOrta,
    havuzBoyutu: ortaHavuzu.length,
  )];

  // Kapanış: banttan bağımsız genel havuz.
  final String kapanis =
      FortunePools.kapanisCumleleri[motor.tekrarsizSecimIndeksi(
    kullanici: kullanici,
    gun: gun,
    amac: ContentConfig.amacKapanis,
    havuzBoyutu: FortunePools.kapanisCumleleri.length,
  )];

  final SansRengi renk =
      FortunePools.sansRenkleri[motor.tekrarsizSecimIndeksi(
    kullanici: kullanici,
    gun: gun,
    amac: ContentConfig.amacRenk,
    havuzBoyutu: FortunePools.sansRenkleri.length,
  )];

  final int sansliSayi = ContentConfig.sansliSayiMin +
      motor.secimIndeksi(
        kullanici: kullanici,
        gun: gun,
        amac: ContentConfig.amacSayi,
        havuzBoyutu:
            ContentConfig.sansliSayiMaks - ContentConfig.sansliSayiMin + 1,
      );

  final String tavsiye =
      FortunePools.gununTavsiyeleri[motor.tekrarsizSecimIndeksi(
    kullanici: kullanici,
    gun: gun,
    amac: ContentConfig.amacTavsiye,
    havuzBoyutu: FortunePools.gununTavsiyeleri.length,
  )];

  return GununIcerigi(
    yorum: '$acilis $orta $kapanis',
    sansRengi: renk,
    sansliSayi: sansliSayi,
    tavsiye: tavsiye,
  );
}

/// [kategori] detayının 2 cümlelik yorumunu üretir: açılış (kategori ×
/// ton) + tavsiye (kategori).
String kategoriYorumu({
  required LuckEngine motor,
  required UserSeed kullanici,
  required LuckResult sonuc,
  required LuckCategory kategori,
}) {
  final DateTime gun = sonuc.gun;
  final int skor = sonuc.kategoriSkorlari[kategori] ?? 0;

  final List<String> acilisHavuzu = CategoryPools
      .kategoriAcilislari[kategori]![KategoriTonu.tonuBul(skor)]!;
  final String acilis = acilisHavuzu[motor.tekrarsizSecimIndeksi(
    kullanici: kullanici,
    gun: gun,
    amac: ContentConfig.kategoriAmaci(kategori, ContentConfig.amacAcilis),
    havuzBoyutu: acilisHavuzu.length,
  )];

  final List<String> tavsiyeHavuzu =
      CategoryPools.kategoriTavsiyeleri[kategori]!;
  final String tavsiye = tavsiyeHavuzu[motor.tekrarsizSecimIndeksi(
    kullanici: kullanici,
    gun: gun,
    amac: ContentConfig.kategoriAmaci(kategori, ContentConfig.amacTavsiye),
    havuzBoyutu: tavsiyeHavuzu.length,
  )];

  return '$acilis $tavsiye';
}

/// Günün "şanslı saatinin" başlangıç saatini (0-23) döndürür.
///
/// Günün baskın kategorisi ([baskinKategori]) seçilir, o kategorinin
/// deterministik şanslı saati ([LuckEngine.sansliSaat]) alınır ve
/// başlangıç saati döndürülür. Şanslı saat bildirimi bunu kullanır.
/// Saf ve deterministik: aynı (kullanıcı, saklanan sonuç) aynı saat.
int gununSansliSaatBaslangici({
  required LuckEngine motor,
  required UserSeed kullanici,
  required LuckResult sonuc,
}) {
  final LuckCategory baskin = baskinKategori(sonuc.kategoriSkorlari);
  return motor
      .sansliSaat(kullanici: kullanici, gun: sonuc.gun, kategori: baskin)
      .baslangicSaati;
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
