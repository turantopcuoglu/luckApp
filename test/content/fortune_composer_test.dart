import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/category_pools.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/fortune_pools.dart';
import 'package:kader/core/content/gunun_icerigi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  const LuckEngine motor = LuckEngine();
  final UserSeed turan = UserSeed.fromIsim(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );
  final DateTime gun = DateTime(2026, 7, 6);

  /// Sabit skorlarla elle kurulmuş sonuç (bant/ton doğrulama için).
  LuckResult sonucKur({
    required int genelSkor,
    required Map<LuckCategory, int> skorlar,
    DateTime? hangiGun,
  }) =>
      LuckResult(
        gun: hangiGun ?? gun,
        genelSkor: genelSkor,
        kategoriSkorlari: skorlar,
        modifiyerler: const <LuckModifier>[],
      );

  group('gununIcerigi', () {
    test('deterministik: aynı (kullanıcı, sonuç) aynı içerik paketi', () {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: gun);
      final GununIcerigi a =
          gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc);
      final GununIcerigi b =
          gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc);
      expect(a, b);
    });

    test('30 ardışık günde yorumlar çeşitleniyor (>20 farklı)', () {
      final Set<String> yorumlar = <String>{};
      for (int i = 0; i < 30; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: g);
        yorumlar.add(
          gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc).yorum,
        );
      }
      expect(yorumlar.length, greaterThan(20));
    });

    test('ardışık iki gün aynı yorum gelmez (60 gün)', () {
      // Asıl gereksinim: günlük yorum cümlesi peş peşe tekrar etmemeli.
      // Yorum üç bağımsız cümleden oluştuğu ve her biri
      // tekrarsizSecimIndeksi ile seçildiği için ardışık gün asla
      // birebir aynı olmaz.
      String? oncekiYorum;
      for (int i = 0; i < 60; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: g);
        final String bugunYorum =
            gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc).yorum;
        if (oncekiYorum != null) {
          expect(bugunYorum, isNot(oncekiYorum),
              reason: '$g yorumu bir öncekiyle aynı');
        }
        oncekiYorum = bugunYorum;
      }
    });

    test('tek bileşenler (renk/tavsiye) ardışık tekrarı büyük ölçüde azalır',
        () {
      // Tek bileşenli alanlarda tekrarsizSecimIndeksi tek-adım garanti
      // verir; nadir uç durumda (bir önceki gün kaydırılmışsa) ardışık
      // çakışma olabilir. 60 günde bu, elle sayılabilir kadar seyrek olmalı.
      int renkTekrar = 0;
      int tavsiyeTekrar = 0;
      GununIcerigi? onceki;
      for (int i = 0; i < 60; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: g);
        final GununIcerigi bugun =
            gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc);
        if (onceki != null) {
          if (bugun.sansRengi.ad == onceki.sansRengi.ad) renkTekrar++;
          if (bugun.tavsiye == onceki.tavsiye) tavsiyeTekrar++;
        }
        onceki = bugun;
      }
      expect(renkTekrar, lessThanOrEqualTo(2));
      expect(tavsiyeTekrar, lessThanOrEqualTo(2));
    });

    test('şanslı sayı her zaman sınırlar içinde', () {
      for (int i = 0; i < 365; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: g);
        final GununIcerigi icerik =
            gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc);
        expect(
          icerik.sansliSayi,
          inInclusiveRange(
            ContentConfig.sansliSayiMin,
            ContentConfig.sansliSayiMaks,
          ),
        );
      }
    });

    test('açılış cümlesi genel skorun bandından gelir', () {
      final Map<SkorBandi, int> ornekSkorlar = <SkorBandi, int>{
        SkorBandi.cokDusuk: 5,
        SkorBandi.dusuk: 25,
        SkorBandi.orta: 50,
        SkorBandi.yuksek: 75,
        SkorBandi.cokYuksek: 95,
      };
      for (final MapEntry<SkorBandi, int> girdi in ornekSkorlar.entries) {
        final LuckResult sonuc = sonucKur(
          genelSkor: girdi.value,
          skorlar: <LuckCategory, int>{
            for (final LuckCategory k in LuckCategory.values) k: girdi.value,
          },
        );
        final GununIcerigi icerik =
            gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc);
        final bool bandtanGeliyor = FortunePools
            .acilisCumleleri[girdi.key]!
            .any(icerik.yorum.startsWith);
        expect(bandtanGeliyor, isTrue,
            reason: '${girdi.key} bandı açılışı yanlış havuzdan');
      }
    });

    test('orta cümle baskın kategorinin havuzundan gelir', () {
      // Para açık ara baskın ve yüksek tonda.
      final LuckResult sonuc = sonucKur(
        genelSkor: 70,
        skorlar: <LuckCategory, int>{
          LuckCategory.ask: 50,
          LuckCategory.para: 90,
          LuckCategory.saglik: 40,
          LuckCategory.risk: 30,
          LuckCategory.sosyal: 45,
        },
      );
      final GununIcerigi icerik =
          gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc);
      final bool paradanGeliyor = FortunePools
          .ortaCumleleri[LuckCategory.para]![KategoriTonu.yuksek]!
          .any(icerik.yorum.contains);
      expect(paradanGeliyor, isTrue);
    });

    test('tavsiye ve kapanış kendi havuzlarından gelir', () {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: gun);
      final GununIcerigi icerik =
          gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc);
      expect(FortunePools.gununTavsiyeleri, contains(icerik.tavsiye));
      final bool kapanisVar =
          FortunePools.kapanisCumleleri.any(icerik.yorum.endsWith);
      expect(kapanisVar, isTrue);
      expect(FortunePools.sansRenkleri, contains(icerik.sansRengi));
    });

    test('10 günlük örnek çıktı okunaklı (gözle kontrol)', () {
      // Doğrulama planı madde 3: Türkçe akıcılık gözle kontrol edilir.
      for (int i = 0; i < 10; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: g);
        final GununIcerigi icerik =
            gununIcerigi(motor: motor, kullanici: turan, sonuc: sonuc);
        // ignore: avoid_print
        print('${g.day}.${g.month}: ${icerik.yorum} | '
            '${icerik.sansRengi.ad} | ${icerik.sansliSayi} | '
            '${icerik.tavsiye}');
        expect(icerik.yorum.split('. ').length, greaterThanOrEqualTo(2));
      }
    });
  });

  group('gununSansliSaatBaslangici', () {
    test('baskın kategorinin şanslı saatinin başlangıcını verir', () {
      // Para açık ara baskın.
      final LuckResult sonuc = sonucKur(
        genelSkor: 70,
        skorlar: <LuckCategory, int>{
          LuckCategory.ask: 40,
          LuckCategory.para: 90,
          LuckCategory.saglik: 30,
          LuckCategory.risk: 20,
          LuckCategory.sosyal: 25,
        },
      );
      final int beklenen = motor
          .sansliSaat(kullanici: turan, gun: gun, kategori: LuckCategory.para)
          .baslangicSaati;
      expect(
        gununSansliSaatBaslangici(motor: motor, kullanici: turan, sonuc: sonuc),
        beklenen,
      );
    });

    test('deterministik ve 8-20 aralığında', () {
      for (int i = 0; i < 60; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: g);
        final int a = gununSansliSaatBaslangici(
            motor: motor, kullanici: turan, sonuc: sonuc);
        final int b = gununSansliSaatBaslangici(
            motor: motor, kullanici: turan, sonuc: sonuc);
        expect(a, b);
        expect(a, inInclusiveRange(8, 20));
      }
    });
  });

  group('baskinKategori', () {
    test('en yüksek skorlu kategori seçilir', () {
      final LuckCategory baskin = baskinKategori(<LuckCategory, int>{
        LuckCategory.ask: 10,
        LuckCategory.para: 20,
        LuckCategory.saglik: 90,
        LuckCategory.risk: 30,
        LuckCategory.sosyal: 40,
      });
      expect(baskin, LuckCategory.saglik);
    });

    test('eşitlikte enum sırasında önce gelen kazanır', () {
      final LuckCategory baskin = baskinKategori(<LuckCategory, int>{
        LuckCategory.ask: 80,
        LuckCategory.para: 50,
        LuckCategory.saglik: 50,
        LuckCategory.risk: 50,
        LuckCategory.sosyal: 80,
      });
      expect(baskin, LuckCategory.ask);
    });

    test('map ekleme sırası sonucu etkilemez (Hive round-trip guard)', () {
      final Map<LuckCategory, int> duz = <LuckCategory, int>{
        LuckCategory.ask: 60,
        LuckCategory.para: 70,
        LuckCategory.saglik: 30,
        LuckCategory.risk: 70,
        LuckCategory.sosyal: 20,
      };
      final Map<LuckCategory, int> ters = <LuckCategory, int>{
        LuckCategory.sosyal: 20,
        LuckCategory.risk: 70,
        LuckCategory.saglik: 30,
        LuckCategory.para: 70,
        LuckCategory.ask: 60,
      };
      expect(baskinKategori(duz), baskinKategori(ters));
      expect(baskinKategori(duz), LuckCategory.para);
    });
  });

  group('kategoriYorumu', () {
    test('deterministik: aynı girdiler aynı yorum', () {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: gun);
      final String a = kategoriYorumu(
        motor: motor,
        kullanici: turan,
        sonuc: sonuc,
        kategori: LuckCategory.ask,
      );
      final String b = kategoriYorumu(
        motor: motor,
        kullanici: turan,
        sonuc: sonuc,
        kategori: LuckCategory.ask,
      );
      expect(a, b);
    });

    test('doğru (kategori, ton) havuzundan açılış + tavsiye içerir', () {
      final LuckResult sonuc = sonucKur(
        genelSkor: 50,
        skorlar: <LuckCategory, int>{
          for (final LuckCategory k in LuckCategory.values) k: 90,
        },
      );
      for (final LuckCategory kategori in LuckCategory.values) {
        final String yorum = kategoriYorumu(
          motor: motor,
          kullanici: turan,
          sonuc: sonuc,
          kategori: kategori,
        );
        final bool acilisDogru = CategoryPools
            .kategoriAcilislari[kategori]![KategoriTonu.yuksek]!
            .any(yorum.startsWith);
        final bool tavsiyeDogru =
            CategoryPools.kategoriTavsiyeleri[kategori]!.any(yorum.endsWith);
        expect(acilisDogru, isTrue, reason: '$kategori açılışı yanlış');
        expect(tavsiyeDogru, isTrue, reason: '$kategori tavsiyesi yanlış');
      }
    });

    test('kategoriler aynı gün farklı yorumlar üretir', () {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: gun);
      final Set<String> yorumlar = <String>{
        for (final LuckCategory k in LuckCategory.values)
          kategoriYorumu(
            motor: motor,
            kullanici: turan,
            sonuc: sonuc,
            kategori: k,
          ),
      };
      expect(yorumlar.length, LuckCategory.values.length);
    });
  });
}
