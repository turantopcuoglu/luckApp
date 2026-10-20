import 'package:flutter/cupertino.dart' show CupertinoDatePicker;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/burc.dart';
import 'package:kader/core/storage/kayitli_kisi.dart';
import 'package:kader/features/compatibility/uyum_screen.dart';

import '../test_ortami.dart';

void main() {
  // Regresyon: seçilen doğum tarihi autoDispose provider'da kayboluyor ve
  // kişi 1 Ocak 2000 (Oğlak) olarak kaydediliyordu.
  testWidgets('kişi formu seçilen doğum tarihini kaydeder', (
    WidgetTester tester,
  ) async {
    KayitliKisi? sonuc;
    await tester.pumpWidget(
      ProviderScope(
        child: testUygulamasi(
          Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () async {
                sonuc = await Navigator.of(context).push<KayitliKisi>(
                  MaterialPageRoute<KayitliKisi>(
                    builder: (_) => const KisiEkleScreen(),
                  ),
                );
              },
              child: const Text('aç'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('kisi-ad-alani')), 'Ece');
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(1999, 10, 14));
    // Kullanıcı tarihi seçtikten sonra ekranla etkileşime devam eder.
    await tester.pumpAndSettle();

    await tester.tap(find.text(trMetinler.uyumKaydet));
    await tester.pumpAndSettle();

    expect(sonuc, isNotNull);
    expect(sonuc!.dogumTarihi, DateTime(1999, 10, 14));
    expect(sonuc!.profil.burc, Burc.terazi);
  });
}
