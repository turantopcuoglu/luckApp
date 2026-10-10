import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/arac_metinleri.dart';
import 'package:kader/core/content/rapor_metinleri.dart';
import 'package:kader/core/content/sayi_metinleri.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/home/ana_kabuk.dart';
import 'package:kader/features/home/ana_sekme.dart';
import 'package:kader/features/profile/profile_strings.dart';
import 'package:kader/features/share/arac_story_card.dart';
import 'package:kader/features/tools/bebek_ismi_screen.dart';
import 'package:kader/features/tools/isim_analizi_screen.dart';
import 'package:kader/features/tools/numara_analizi_screen.dart';
import 'package:kader/features/tools/tools_providers.dart';
import 'package:kader/features/tools/tools_screen.dart';
import 'package:kader/features/tools/tools_strings.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  final DateTime sabitGun = DateTime(2026, 10, 3);
  // Yaşam yolu 4 (grup {2,4,8}).
  final UserProfile ayse = UserProfile(
    isim: 'Ayşe',
    dogumTarihi: DateTime(1994, 3, 14),
    tamAd: 'Ayşe Yılmaz',
    onboardingTamam: true,
    uyariKabulSurumu: 1,
  );
  late List<AracPaylasimi> paylasilanlar;

  Future<void> hazirla() async {
    await ortam.kur('tools_test');
    await ortam.profil.put(StorageKeys.profilKaydi, ayse.toMap());
    await ortam.kayit.put(
      gunAnahtari(sabitGun),
      DailyRecord(
        sonuc: const LuckEngine().hesapla(kullanici: ayse.seed, gun: sabitGun),
      ).toMap(),
    );
  }

  Future<void> ac(
    WidgetTester tester,
    Widget ev, {
    bool premium = false,
  }) async {
    paylasilanlar = <AracPaylasimi>[];
    await tester.runAsync(hazirla);
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(
            gun: sabitGun,
            premium: premium,
            ek: <Override>[
              aracPaylasProvider.overrideWithValue(
                (AracPaylasimi p) async => paylasilanlar.add(p),
              ),
            ],
          ),
          child: testUygulamasi(ev),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  Future<void> yazVeHesapla(WidgetTester tester, String metin) async {
    await tester.enterText(find.byType(TextField), metin);
    await tester.tap(find.text(ToolsStrings.hesapla));
    await tester.pump();
  }

  test('adaylariAyir: satır ve virgülden ayırır, boşları atar, sınırlar', () {
    expect(adaylariAyir(' Ada Yılmaz \n\nCan, Ali '), <String>[
      'Ada Yılmaz',
      'Can',
      'Ali',
    ]);
    expect(adaylariAyir(List<String>.filled(20, 'A').join(',')), hasLength(10));
  });

  testWidgets('Keşfet sekmesi alt gezinmede; üç araç kartı açılır', (
    WidgetTester tester,
  ) async {
    await ac(tester, const AnaKabuk());
    await tester.tap(find.text(AnaSekme.kesfet.etiketi(trMetinler)));
    await tester.pump();
    expect(find.byType(ToolsScreen), findsOneWidget);
    expect(find.text(ToolsStrings.isimBaslik), findsOneWidget);
    expect(find.text(ToolsStrings.numaraBaslik), findsOneWidget);
    expect(find.text(ToolsStrings.bebekBaslik), findsOneWidget);

    await tester.tap(find.text(ToolsStrings.numaraBaslik));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(NumaraAnaliziScreen), findsOneWidget);
  });

  group('NumaraAnaliziScreen', () {
    testWidgets('telefon 11: sayı, lakap, hesap satırı, paylaşım', (
      WidgetTester tester,
    ) async {
      await ac(tester, const NumaraAnaliziScreen());
      await yazVeHesapla(tester, '0532 123 45 67');

      expect(find.text('11'), findsOneWidget);
      expect(find.text('Usta İlham'), findsOneWidget);
      expect(find.text('Toplam 38 → 11'), findsOneWidget);
      expect(find.text(AracMetinleri.numaralar[11]!.metin), findsOneWidget);

      await tester.tap(find.text(ToolsStrings.paylas));
      await tester.pump();
      final AracPaylasimi p = paylasilanlar.single;
      expect(p.ustEtiket, ToolsStrings.numaraKartEtiketi);
      expect(p.baslik, '0532 123 45 67');
      expect(p.sayi, '11');
      expect(p.sayiEtiketi, 'Usta İlham');
      expect(p.metin, AracMetinleri.numaralar[11]!.metin);
    });

    testWidgets('harf/rakam yoksa uyarı', (WidgetTester tester) async {
      await ac(tester, const NumaraAnaliziScreen());
      await yazVeHesapla(tester, '---');
      expect(find.text(ToolsStrings.gecersiz), findsOneWidget);
    });
  });

  group('IsimAnaliziScreen', () {
    testWidgets('sayılar açık, derin bölümler kilitli', (
      WidgetTester tester,
    ) async {
      await ac(tester, const IsimAnaliziScreen());
      await yazVeHesapla(tester, 'Ayşe Yılmaz');

      expect(find.text('İsim sayısı 1'), findsOneWidget);
      expect(find.text('Ruh sayısı 7'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(RaporMetinleri.karmikDersBasligi),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(ProfileStrings.kilidiAc), findsWidgets);
    });

    testWidgets('premium kullanıcıda kilit yok; paylaşım ücretsiz '
        'başlıkları içerir', (WidgetTester tester) async {
      await ac(tester, const IsimAnaliziScreen(), premium: true);
      await yazVeHesapla(tester, 'Ayşe Yılmaz');
      expect(find.text(ProfileStrings.kilidiAc), findsNothing);

      await tester.scrollUntilVisible(
        find.text(ToolsStrings.paylas),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(ToolsStrings.paylas));
      await tester.pump();
      final AracPaylasimi p = paylasilanlar.single;
      expect(p.ustEtiket, ToolsStrings.isimKartEtiketi);
      expect(p.baslik, 'Ayşe Yılmaz');
      expect(p.sayi, '1');
      expect(p.metin, SayiMetinleri.isimSayisi[1]);
    });
  });

  group('BebekIsmiScreen', () {
    testWidgets('ilk aday ücretsiz; sıralama kilitli', (
      WidgetTester tester,
    ) async {
      await ac(tester, const BebekIsmiScreen());
      expect(find.text(ToolsStrings.ben('Ayşe')), findsOneWidget);

      // Ada Yılmaz → 11 (taban 2) ile Ayşe 4: aynı grup → 95.
      await yazVeHesapla(tester, 'Ada Yılmaz\nAli Yılmaz');
      await tester.scrollUntilVisible(
        find.text('Ada Yılmaz'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Uyum 95/100 · Çok uyumlu'), findsOneWidget);
      expect(
        find.textContaining('Ayşe ile aynı doğal ritimde'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text(ToolsStrings.siralamaBaslik),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(ProfileStrings.kilidiAc), findsOneWidget);
    });

    testWidgets('premium: tüm adaylar puana göre sıralı', (
      WidgetTester tester,
    ) async {
      await ac(tester, const BebekIsmiScreen(), premium: true);
      // Ali Yılmaz → 9 ile 4: zorlayıcı → 60; Ada 95.
      await yazVeHesapla(tester, 'Ali Yılmaz\nAda Yılmaz');
      await tester.scrollUntilVisible(
        find.text(ToolsStrings.siralamaBaslik),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('1. Ada Yılmaz · 95\n2. Ali Yılmaz · 60'),
        findsOneWidget,
      );
    });

    testWidgets('kimse seçili değilse hesaplanamaz', (
      WidgetTester tester,
    ) async {
      await ac(tester, const BebekIsmiScreen());
      await tester.tap(find.text(ToolsStrings.ben('Ayşe')));
      await tester.pump();
      expect(find.text(ToolsStrings.kisiSec), findsOneWidget);
      final FilledButton buton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, ToolsStrings.hesapla),
      );
      expect(buton.onPressed, isNull);
    });
  });
}
