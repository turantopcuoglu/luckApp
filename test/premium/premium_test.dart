import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/uygulama_durumu.dart';
import 'package:kader/features/ads/ads_config.dart';
import 'package:kader/features/ads/ads_providers.dart';
import 'package:kader/features/premium/magaza_servisi.dart';
import 'package:kader/features/premium/paywall_screen.dart';
import 'package:kader/features/premium/premium_config.dart';
import 'package:kader/features/premium/premium_kontrolcu.dart';
import 'package:kader/features/premium/premium_strings.dart';

import '../test_ortami.dart';

/// Satın alma olaylarını elle yayınlayan sahte mağaza.
class SahteMagaza implements MagazaServisi {
  final StreamController<List<SatinAlmaGuncellemesi>> _akis =
      StreamController<List<SatinAlmaGuncellemesi>>.broadcast();

  /// Geri yüklemede yayınlanacak liste.
  List<SatinAlmaGuncellemesi> geriYuklenecek = <SatinAlmaGuncellemesi>[];

  /// Tamamlanan (acknowledge) satın alımlar.
  final List<SatinAlmaGuncellemesi> tamamlananlar = <SatinAlmaGuncellemesi>[];

  /// Satın alınmaya çalışılan planlar.
  final List<AbonelikPlani> satinAlinanlar = <AbonelikPlani>[];

  /// Mağaza erişilebilir mi?
  bool kullanilabilir = true;

  /// Dönen planlar.
  List<AbonelikPlani> planlar = const <AbonelikPlani>[
    AbonelikPlani(
      urunId: PremiumConfig.yillikUrunId,
      fiyatMetni: '₺600,00',
      hamFiyat: 600,
      yillikMi: true,
      denemeGunu: 7,
    ),
    AbonelikPlani(
      urunId: PremiumConfig.aylikUrunId,
      fiyatMetni: '₺100,00',
      hamFiyat: 100,
      yillikMi: false,
    ),
  ];

  /// Akışa olay yayınlar.
  void yayinla(List<SatinAlmaGuncellemesi> liste) => _akis.add(liste);

  @override
  Stream<List<SatinAlmaGuncellemesi>> get guncellemeler => _akis.stream;

  @override
  Future<bool> kullanilabilirMi() async => kullanilabilir;

  @override
  Future<List<AbonelikPlani>> planlariGetir() async => planlar;

  @override
  Future<bool> satinAl(AbonelikPlani plan) async {
    satinAlinanlar.add(plan);
    return true;
  }

  @override
  Future<void> geriYukle() async => scheduleMicrotask(
        () => _akis.add(geriYuklenecek),
      );

  @override
  Future<void> tamamla(SatinAlmaGuncellemesi guncelleme) async =>
      tamamlananlar.add(guncelleme);
}

void main() {
  final TestOrtami ortam = TestOrtami();
  late SahteMagaza magaza;
  late DateTime simdi;

  setUp(() async {
    await ortam.kur('premium_test');
    magaza = SahteMagaza();
    simdi = DateTime(2026, 9, 13, 12);
  });

  ProviderContainer kapsayici() {
    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[
        appStateBoxProvider.overrideWithValue(ortam.durum),
        magazaServisiProvider.overrideWithValue(magaza),
        saatProvider.overrideWithValue(() => simdi),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> bekle() => Future<void>.delayed(Duration.zero);

  group('PremiumKontrolcu', () {
    test('açılışta aktif abonelik geri yüklenirse premium açılır ve önbelleğe '
        'yazılır; teslim onayı yapılır', () async {
      magaza.geriYuklenecek = <SatinAlmaGuncellemesi>[
        const SatinAlmaGuncellemesi(
          urunId: PremiumConfig.yillikUrunId,
          durum: SatinAlmaDurumu.geriYuklendi,
          tamamlanmaBekliyor: true,
        ),
      ];
      final ProviderContainer c = kapsayici();
      await c.read(premiumKontrolcuProvider.notifier).baslat();
      await bekle();
      await bekle();

      expect(c.read(premiumKontrolcuProvider).aktif, isTrue);
      expect(c.read(premiumKontrolcuProvider).planlar, hasLength(2));
      expect(magaza.tamamlananlar, hasLength(1));
      final UygulamaDurumu durum =
          UygulamaDurumuRepository(ortam.durum).durum;
      expect(durum.premiumAktif, isTrue);
      expect(durum.premiumUrunId, PremiumConfig.yillikUrunId);
    });

    test('geri yükleme boş dönerse önbellekteki premium kapanır', () async {
      await UygulamaDurumuRepository(ortam.durum).premiumuKaydet(
        aktif: true,
        dogrulama: simdi,
        urunId: PremiumConfig.aylikUrunId,
      );
      final ProviderContainer c = kapsayici();
      expect(c.read(premiumKontrolcuProvider).aktif, isTrue);

      await c.read(premiumKontrolcuProvider.notifier).baslat();
      await bekle();
      await bekle();

      expect(c.read(premiumKontrolcuProvider).aktif, isFalse);
      expect(UygulamaDurumuRepository(ortam.durum).durum.premiumAktif, isFalse);
    });

    test('mağaza yokken önbellek tolerans süresi boyunca geçerli', () async {
      magaza.kullanilabilir = false;
      await UygulamaDurumuRepository(ortam.durum).premiumuKaydet(
        aktif: true,
        dogrulama: simdi.subtract(const Duration(days: 3)),
      );
      final ProviderContainer c = kapsayici();
      await c.read(premiumKontrolcuProvider.notifier).baslat();
      expect(c.read(premiumKontrolcuProvider).aktif, isTrue);
      expect(c.read(premiumKontrolcuProvider).magazaKullanilabilir, isFalse);

      simdi = simdi.add(PremiumConfig.cevrimdisiTolerans);
      final ProviderContainer c2 = kapsayici();
      expect(c2.read(premiumKontrolcuProvider).aktif, isFalse);
    });

    test('satın alma olayı premium açar; başka ürün açmaz', () async {
      final ProviderContainer c = kapsayici();
      await c.read(premiumKontrolcuProvider.notifier).baslat();
      await bekle();

      magaza.yayinla(<SatinAlmaGuncellemesi>[
        const SatinAlmaGuncellemesi(
          urunId: 'baska_urun',
          durum: SatinAlmaDurumu.satinAlindi,
          tamamlanmaBekliyor: false,
        ),
      ]);
      await bekle();
      expect(c.read(premiumKontrolcuProvider).aktif, isFalse);

      await c
          .read(premiumKontrolcuProvider.notifier)
          .satinAl(magaza.planlar.last);
      expect(magaza.satinAlinanlar.single.urunId, PremiumConfig.aylikUrunId);
      magaza.yayinla(<SatinAlmaGuncellemesi>[
        const SatinAlmaGuncellemesi(
          urunId: PremiumConfig.aylikUrunId,
          durum: SatinAlmaDurumu.satinAlindi,
          tamamlanmaBekliyor: true,
        ),
      ]);
      await bekle();
      await bekle();
      expect(c.read(premiumKontrolcuProvider).aktif, isTrue);
      expect(c.read(premiumKontrolcuProvider).islemde, isFalse);
    });

    test('bekleyen ödeme ve hata kullanıcıya mesaj olarak yansır', () async {
      final ProviderContainer c = kapsayici();
      await c.read(premiumKontrolcuProvider.notifier).baslat();
      await bekle();

      magaza.yayinla(<SatinAlmaGuncellemesi>[
        const SatinAlmaGuncellemesi(
          urunId: PremiumConfig.yillikUrunId,
          durum: SatinAlmaDurumu.beklemede,
          tamamlanmaBekliyor: false,
        ),
      ]);
      await bekle();
      expect(
        c.read(premiumKontrolcuProvider).hataMesaji,
        PremiumHatalari.odemeBekleniyor,
      );
      expect(c.read(premiumKontrolcuProvider).aktif, isFalse);
    });
  });

  group('gecisReklamiGosterilebilir', () {
    final DateTime ilk = DateTime(2026, 9, 1);

    test('premium ve ilk günlerde gösterilmez', () {
      expect(
        gecisReklamiGosterilebilir(
          simdi: DateTime(2026, 9, 10),
          premium: true,
          ilkAcilis: ilk,
          sonGosterim: null,
        ),
        isFalse,
      );
      expect(
        gecisReklamiGosterilebilir(
          simdi: ilk.add(const Duration(days: AdsConfig.gecisIcinEnAzGun - 1)),
          premium: false,
          ilkAcilis: ilk,
          sonGosterim: null,
        ),
        isFalse,
      );
    });

    test('aralık dolmadan tekrar gösterilmez, dolunca gösterilir', () {
      final DateTime son = DateTime(2026, 9, 10, 8);
      expect(
        gecisReklamiGosterilebilir(
          simdi: son.add(const Duration(hours: 5)),
          premium: false,
          ilkAcilis: ilk,
          sonGosterim: son,
        ),
        isFalse,
      );
      expect(
        gecisReklamiGosterilebilir(
          simdi: son.add(AdsConfig.gecisReklamiAraligi),
          premium: false,
          ilkAcilis: ilk,
          sonGosterim: son,
        ),
        isTrue,
      );
    });
  });

  group('PaywallScreen', () {
    testWidgets('planları gösterir, yıllık varsayılan; satın al çağrılır',
        (WidgetTester tester) async {
      final ProviderContainer c = kapsayici();
      await tester.runAsync(
        () => c.read(premiumKontrolcuProvider.notifier).planlariYukle(),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(home: PaywallScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('₺600,00 / yıl'), findsOneWidget);
      expect(find.text('₺100,00 / ay'), findsOneWidget);
      expect(find.text(PremiumStrings.enAvantajli), findsOneWidget);
      expect(find.text(PremiumStrings.deneme(7)), findsOneWidget);
      expect(find.text(PremiumStrings.ayliginaDusen('₺50,00')), findsOneWidget);

      // Varsayılan yıllık (deneme var) → buton deneme metni.
      await tester.scrollUntilVisible(
        find.text(PremiumStrings.denemeBaslat),
        100,
      );
      await tester.tap(find.text(PremiumStrings.denemeBaslat));
      await tester.pump();
      expect(magaza.satinAlinanlar.single.urunId, PremiumConfig.yillikUrunId);
    });
  });
}
