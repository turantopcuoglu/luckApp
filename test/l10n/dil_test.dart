import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/icerik_paketi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/uygulama_durumu.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/home/ana_sekme.dart';
import 'package:kader/features/legal/legal_config.dart';
import 'package:kader/l10n/app_localizations.dart';
import 'package:kader/l10n/app_localizations_en.dart';
import 'package:kader/l10n/dil_providers.dart';
import 'package:kader/main.dart';

import '../test_ortami.dart';

/// ARB dosyasındaki çeviri anahtarları (`@` meta anahtarları hariç).
Map<String, String> _arb(String dil) {
  final Map<String, dynamic> ham =
      jsonDecode(File('lib/l10n/app_$dil.arb').readAsStringSync())
          as Map<String, dynamic>;
  return <String, String>{
    for (final MapEntry<String, dynamic> e in ham.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

/// Metindeki `{yerTutucu}` adları.
Set<String> _yerTutucular(String metin) => RegExp(
  r'\{(\w+)\}',
).allMatches(metin).map((RegExpMatch m) => m.group(1)!).toSet();

void main() {
  group('uygulamaDiliniCoz (K3)', () {
    test('İngilizce yayında değilken tercih yoksa her cihazda Türkçe', () {
      for (final String kod in <String>['tr', 'en', 'de']) {
        expect(
          uygulamaDiliniCoz(
            tercih: null,
            cihazDilKodu: kod,
            ingilizceYayinda: false,
          ),
          IcerikDili.tr,
          reason: kod,
        );
      }
    });

    test('İngilizce yayındayken cihaz dili tr ise Türkçe, değilse '
        'İngilizce', () {
      expect(
        uygulamaDiliniCoz(
          tercih: null,
          cihazDilKodu: 'tr',
          ingilizceYayinda: true,
        ),
        IcerikDili.tr,
      );
      for (final String kod in <String>['en', 'de', 'ar']) {
        expect(
          uygulamaDiliniCoz(
            tercih: null,
            cihazDilKodu: kod,
            ingilizceYayinda: true,
          ),
          IcerikDili.en,
          reason: kod,
        );
      }
    });

    test('Ayarlar tercihi her durumda önce gelir', () {
      for (final bool yayinda in <bool>[false, true]) {
        expect(
          uygulamaDiliniCoz(
            tercih: IcerikDili.en,
            cihazDilKodu: 'tr',
            ingilizceYayinda: yayinda,
          ),
          IcerikDili.en,
        );
        expect(
          uygulamaDiliniCoz(
            tercih: IcerikDili.tr,
            cihazDilKodu: 'en',
            ingilizceYayinda: yayinda,
          ),
          IcerikDili.tr,
        );
      }
    });

    test('dil kodu çevirisi ve locale', () {
      expect(dilKodundan('tr'), IcerikDili.tr);
      expect(dilKodundan('en'), IcerikDili.en);
      expect(dilKodundan(null), isNull);
      expect(dilKodundan('xx'), isNull);
      expect(dilLocale(IcerikDili.en), const Locale('en'));
    });
  });

  group('ARB dosyaları', () {
    test('Türkçe ve İngilizce aynı anahtarları ve yer tutucuları taşır', () {
      final Map<String, String> tr = _arb('tr');
      final Map<String, String> en = _arb('en');
      expect(en.keys.toSet(), tr.keys.toSet());
      for (final String a in tr.keys) {
        expect(_yerTutucular(en[a]!), _yerTutucular(tr[a]!), reason: a);
        expect(en[a], isNotEmpty, reason: a);
      }
    });

    test('desteklenen diller içerik dilleriyle aynı', () {
      expect(
        AppLocalizations.supportedLocales
            .map((Locale l) => l.languageCode)
            .toSet(),
        IcerikDili.values.map((IcerikDili d) => d.name).toSet(),
      );
    });
  });

  group('dil tercihi deposu', () {
    final TestOrtami ortam = TestOrtami();
    setUp(() => ortam.kur('dil_test'));

    test('kaydedilir, premium kaydı onu silmez, null ile temizlenir', () async {
      final UygulamaDurumuRepository repo = UygulamaDurumuRepository(
        ortam.durum,
      );
      expect(repo.durum.dilKodu, isNull);

      await repo.dilKaydet('en');
      expect(repo.durum.dilKodu, 'en');

      await repo.premiumuKaydet(
        aktif: true,
        dogrulama: DateTime(2026, 10, 8),
        urunId: 'kader_premium_aylik',
      );
      expect(repo.durum.dilKodu, 'en');
      expect(repo.durum.premiumAktif, isTrue);

      await repo.dilKaydet(null);
      expect(repo.durum.dilKodu, isNull);
      expect(repo.durum.premiumAktif, isTrue);
    });

    test(
      'provider: tercih kayıttan okunur ve uygulama dilini belirler',
      () async {
        await UygulamaDurumuRepository(ortam.durum).dilKaydet('en');
        final ProviderContainer c = ProviderContainer(
          overrides: ortam.overridelar(
            gun: DateTime(2026, 10, 8),
            ek: <Override>[cihazDilKoduProvider.overrideWithValue('tr')],
          ),
        );
        addTearDown(c.dispose);

        expect(c.read(dilTercihiProvider), IcerikDili.en);
        expect(c.read(uygulamaDiliProvider), IcerikDili.en);

        await c.read(dilTercihiProvider.notifier).sec(null);
        expect(c.read(uygulamaDiliProvider), IcerikDili.tr);
        expect(UygulamaDurumuRepository(ortam.durum).durum.dilKodu, isNull);
      },
    );
  });

  group('Ayarlar dil seçimi', () {
    final TestOrtami ortam = TestOrtami();
    final DateTime sabitGun = DateTime(2026, 7, 6);
    final UserProfile turan = UserProfile(
      isim: 'Turan',
      dogumTarihi: DateTime(1990, 5, 15),
      onboardingTamam: true,
      uyariKabulSurumu: LegalConfig.uyariSurumu,
    );
    setUp(() => ortam.kur('dil_ekran_test'));

    testWidgets('English seçilince arayüz İngilizceye geçer (debug)', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(
        () => ortam.profil.put(StorageKeys.profilKaydi, turan.toMap()),
      );
      final LuckResult sonuc = const LuckEngine().hesapla(
        kullanici: turan.seed,
        gun: sabitGun,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(
            gun: sabitGun,
            ek: <Override>[
              gununSansiProvider.overrideWith(
                (Ref ref) => Future<LuckResult>.value(sonuc),
              ),
              cihazDilKoduProvider.overrideWithValue('tr'),
            ],
          ),
          child: const KaderApp(),
        ),
      );
      await tester.pump();
      await tester.pump();

      final AppLocalizations en = AppLocalizationsEn();
      expect(find.text(AnaSekme.bugun.etiketi(trMetinler)), findsOneWidget);

      await tester.tap(find.text(AnaSekme.ayarlar.etiketi(trMetinler)));
      await tester.pump();
      const Key ingilizce = ValueKey<String>('dil_en');
      await tester.scrollUntilVisible(find.byKey(ingilizce), 200);
      await tester.tap(find.byKey(ingilizce));
      await tester.pump();
      await tester.pump();

      expect(find.text(AnaSekme.bugun.etiketi(en)), findsOneWidget);
      expect(find.text(en.ayarlarBaslik), findsWidgets);
      expect(find.text(AnaSekme.bugun.etiketi(trMetinler)), findsNothing);
      // Kalıcılık "dil tercihi deposu" testinde; burada runAsync kullanmak
      // GoogleFonts'un ağdan font indirmesini tetikler (smoke test notu).
    });
  });
}
