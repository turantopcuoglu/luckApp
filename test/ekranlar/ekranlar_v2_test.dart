import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/kayitli_kisi.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/compatibility/uyum_screen.dart';
import 'package:kader/features/compatibility/uyum_sonuc_screen.dart';
import 'package:kader/features/home/ana_kabuk.dart';
import 'package:kader/features/home/ana_sekme.dart';
import 'package:kader/features/legal/legal_texts.dart';
import 'package:kader/features/legal/yasal_belge_screen.dart';
import 'package:kader/features/profile/hesap_metni.dart';
import 'package:kader/features/profile/kader_profili_screen.dart';
import 'package:kader/features/settings/ayarlar_screen.dart';

import 'package:kader/l10n/app_localizations_en.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  final DateTime sabitGun = DateTime(2026, 9, 13);
  final UserProfile ayse = UserProfile(
    isim: 'Ayşe',
    dogumTarihi: DateTime(1994, 3, 14),
    tamAd: 'Ayşe',
    onboardingTamam: true,
    uyariKabulSurumu: 1,
  );

  Future<void> hazirla({UserProfile? profil}) async {
    await ortam.kur('ekranlar_test');
    final UserProfile p = profil ?? ayse;
    await ortam.profil.put(StorageKeys.profilKaydi, p.toMap());
    await ortam.kayit.put(
      gunAnahtari(sabitGun),
      DailyRecord(
        sonuc: const LuckEngine().hesapla(kullanici: p.seed, gun: sabitGun),
      ).toMap(),
    );
  }

  Future<void> ac(
    WidgetTester tester,
    Widget ev, {
    bool premium = false,
  }) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(gun: sabitGun, premium: premium),
          child: testUygulamasi(ev),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  group('hesapSatirlari', () {
    test('yaşam yolu adımları okunur biçimde', () {
      final List<HesapSatiri> satirlar =
          hesapSatirlari(
            Numeroloji.yasamYolu(DateTime(1994, 3, 14)),
            trMetinler,
          );
      expect(
        satirlar.map((HesapSatiri s) => s.islem).toList(),
        <String>[
          '03 → 3',
          '14 → 1+4 = 5',
          '1994 → 1+9+9+4 = 23 → 5',
          '3+5+5 = 13 → 4',
        ],
      );
    });

    test('usta gün korunur, harfler değerleriyle yazılır', () {
      expect(
        hesapSatirlari(
          Numeroloji.yasamYolu(DateTime(2000, 11, 29)),
          trMetinler,
        )[1].islem,
        '29 → 2+9 = 11',
      );
      expect(
        hesapSatirlari(Numeroloji.isimSayisi('Ayşe')!, trMetinler).single.islem,
        'A1 Y7 Ş1 E5 = 14 → 5',
      );
    });

    test('adım etiketleri arayüz dilinde, işlemler iki dilde aynı', () {
      final SayiHesabi hesap = Numeroloji.yasamYolu(DateTime(1994, 3, 14));
      final List<HesapSatiri> tr = hesapSatirlari(hesap, trMetinler);
      final List<HesapSatiri> en = hesapSatirlari(hesap, AppLocalizationsEn());
      expect(tr.first.etiket, trMetinler.profilAdimAy);
      expect(en.first.etiket, 'Birth month');
      expect(
        en.map((HesapSatiri s) => s.islem).toList(),
        tr.map((HesapSatiri s) => s.islem).toList(),
      );
    });

    test('indirgeme zinciri usta sayıda durur', () {
      expect(indirgemeZinciri(29), <int>[29, 11]);
      expect(indirgemeZinciri(38), <int>[38, 11]);
      expect(indirgemeZinciri(7), <int>[7]);
      expect(indirgemeZinciri(1994), <int>[1994, 23, 5]);
    });
  });

  group('KaderProfiliScreen', () {
    testWidgets('sayılar görünür; premium bölümler kilitli, ücretsizler açık',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await ac(tester, const KaderProfiliScreen());

      expect(find.text(trMetinler.profilBaslik), findsOneWidget);
      expect(find.text('4'), findsWidgets); // yaşam yolu
      expect(find.text('5'), findsWidgets); // isim sayısı (Ayşe)
      await tester.scrollUntilVisible(find.text('Özün · Kurucu'), 200);
      expect(find.text('Özün · Kurucu'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Gölge yanın'), 200);
      expect(find.text(trMetinler.profilKilidiAc), findsWidgets);
    });

    testWidgets('yaşam yolu karosu hesap adımlarını gösterir',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await ac(tester, const KaderProfiliScreen());

      // Profil başlık bandı uzun: karo test ekranının altında kalabilir.
      await tester.ensureVisible(find.text(trMetinler.profilYasamYolu));
      await tester.pump();
      await tester.tap(find.text(trMetinler.profilYasamYolu));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(trMetinler.profilNasilHesaplandi), findsOneWidget);
      expect(find.text('1994 → 1+9+9+4 = 23 → 5'), findsOneWidget);
    });

    testWidgets('premium kullanıcıda kilit yok; tam ad yoksa uyarı kartı',
        (WidgetTester tester) async {
      await tester.runAsync(
        () => hazirla(
          profil: UserProfile(
            isim: 'Ayşe',
            dogumTarihi: DateTime(1994, 3, 14),
            onboardingTamam: true,
          ),
        ),
      );
      await ac(tester, const KaderProfiliScreen(), premium: true);

      await tester.scrollUntilVisible(
        find.text(trMetinler.profilTamAdEksikBaslik),
        200,
      );
      expect(find.text(trMetinler.profilTamAdEksikBaslik), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Yaşam dersin'), 200);
      expect(find.text(trMetinler.profilKilidiAc), findsNothing);
    });
  });

  group('UyumScreen', () {
    testWidgets('kişi ekle → sonuç ekranı; ikinci kişi premium ister',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await ac(tester, const UyumScreen());

      expect(find.text(trMetinler.uyumBosDurum), findsOneWidget);
      await tester.tap(find.text(trMetinler.uyumKisiEkle));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.enterText(find.byKey(const Key('kisi-ad-alani')), 'Mert Kaya');
      await tester.tap(find.text(trMetinler.uyumKaydet));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(UyumSonucScreen), findsOneWidget);
      expect(find.text(trMetinler.uyumEtiketi), findsOneWidget);
      expect(KisiRepository(ortam.kisiler).tumu().single.ad, 'Mert Kaya');

      // pageBack() İngilizce "Back" ipucunu arar; arayüz Türkçe yerelleştirildi.
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Mert Kaya'), findsOneWidget);

      await tester.tap(find.text(trMetinler.uyumKisiEkle));
      await tester.pump();
      expect(find.text(trMetinler.premiumKisiSiniri), findsOneWidget);
    });
  });

  group('AyarlarScreen ve kabuk', () {
    testWidgets('profil bilgileri ve yasal belgeler erişilebilir',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await ac(tester, const AyarlarScreen());

      expect(find.text('Ayşe'), findsWidgets);
      await tester.scrollUntilVisible(find.text(YasalBelge.gizlilik.baslik(trMetinler)), 200);
      await tester.tap(find.text(YasalBelge.gizlilik.baslik(trMetinler)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(YasalBelgeScreen), findsOneWidget);
      expect(
        find.text(YasalMetinler.gizlilikPolitikasi.first.baslik),
        findsOneWidget,
      );
    });

    testWidgets('verilerimi sil tüm kutuları temizler',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await ac(tester, const AyarlarScreen());

      await tester.scrollUntilVisible(find.text(trMetinler.ayarlarVerileriSil), 200);
      await tester.tap(find.text(trMetinler.ayarlarVerileriSil));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(trMetinler.ayarlarSil));
      await tester.pump();
      // Kutu temizleme gerçek disk I/O'dur: I/O gerçek event loop'ta
      // (runAsync) tamamlanır, devamı sahte zamanın mikro görevlerinde
      // (pump) çalışır; ikisi dönüşümlü ilerletilir.
      for (int i = 0; i < 10 && ortam.profil.isNotEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }

      expect(ortam.profil.isEmpty, isTrue);
      expect(ortam.kayit.isEmpty, isTrue);
    });

    testWidgets('alt gezinme sekmeleri değiştirir', (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await ac(tester, const AnaKabuk());

      await tester.tap(find.text(AnaSekme.uyum.etiketi(trMetinler)));
      await tester.pump();
      expect(find.text(trMetinler.uyumAciklama), findsOneWidget);

      await tester.tap(find.text(AnaSekme.ayarlar.etiketi(trMetinler)));
      await tester.pump();
      expect(find.text(trMetinler.ayarlarProfil.toUpperCase()), findsOneWidget);
    });
  });
}
