import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/storage/kayitli_kisi.dart';
import 'package:kader/features/compatibility/uyum_screen.dart';
import 'package:kader/l10n/app_localizations.dart';
import 'package:kader/l10n/app_localizations_en.dart';
import 'package:kader/l10n/app_localizations_tr.dart';

/// E6c: ekranda elle yazılmış Türkçe metinlerin ARB'ye taşınması.
void main() {
  final AppLocalizations tr = AppLocalizationsTr();
  final AppLocalizations en = AppLocalizationsEn();

  group('rolEtiketi', () {
    test('Türkçe etiketler taşımadan önceki metinlerle aynı', () {
      expect(
        <String>[for (final KisiRolu r in KisiRolu.values) rolEtiketi(tr, r)],
        <String>['Partnerim', 'Hoşlandığım biri', 'Arkadaşım', 'Ailemden'],
      );
    });

    test('İngilizcede her rolün ayrı, Türkçeden farklı bir adı var', () {
      final List<String> ingilizce = <String>[
        for (final KisiRolu r in KisiRolu.values) rolEtiketi(en, r),
      ];
      expect(ingilizce.toSet(), hasLength(KisiRolu.values.length));
      for (final KisiRolu r in KisiRolu.values) {
        expect(rolEtiketi(en, r), isNot(rolEtiketi(tr, r)));
      }
    });
  });

  test('yaşam yolu anlamı: Türkçe kalıp değişmedi, İngilizce kalıp dolu', () {
    expect(
      tr.profilYasamYoluAnlami('Öncü', 'başlatma gücü'),
      'Öncü: doğanda başlatma gücü var.',
    );
    expect(
      en.profilYasamYoluAnlami('Pioneer', 'drive'),
      'Pioneer: your nature holds drive.',
    );
  });
}
