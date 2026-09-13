import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  LuckResult sonuc(Map<LuckCategory, int> skorlar) => LuckResult(
    gun: DateTime(2026, 9, 5),
    genelSkor: 60,
    kategoriSkorlari: skorlar,
    modifiyerler: const <LuckModifier>[],
  );

  test('eski motor kategori adları ve sırası korunur', () {
    expect(
      LuckCategory.values.map((LuckCategory kategori) => kategori.name),
      <String>['ask', 'para', 'saglik', 'risk', 'sosyal'],
    );
  });

  test('beş alan bire bir ve tersine çevrilebilir eşlenir', () {
    const Map<ExperienceDimension, LuckCategory> beklenen =
        <ExperienceDimension, LuckCategory>{
          ExperienceDimension.akis: LuckCategory.sosyal,
          ExperienceDimension.bag: LuckCategory.ask,
          ExperienceDimension.uretim: LuckCategory.para,
          ExperienceDimension.cesaret: LuckCategory.risk,
          ExperienceDimension.denge: LuckCategory.saglik,
        };
    expect(beklenen.keys.toSet(), ExperienceDimension.values.toSet());
    expect(beklenen.values.toSet(), LuckCategory.values.toSet());
    for (final entry in beklenen.entries) {
      expect(entry.key.kategori, entry.value);
      expect(ExperienceDimension.kategoriden(entry.value), entry.key);
    }
  });

  test('gösterim sırası ve TR/EN adları ürün diline uyar', () {
    expect(ExperienceDimension.gosterimSirasi, <ExperienceDimension>[
      ExperienceDimension.akis,
      ExperienceDimension.bag,
      ExperienceDimension.uretim,
      ExperienceDimension.cesaret,
      ExperienceDimension.denge,
    ]);
    expect(
      ExperienceDimension.gosterimSirasi.map(
        (ExperienceDimension alan) => alan.etiket(AppDil.tr),
      ),
      <String>['Akış', 'Bağ', 'Üretim', 'Cesaret', 'Denge'],
    );
    expect(
      ExperienceDimension.gosterimSirasi.map(
        (ExperienceDimension alan) => alan.etiket(AppDil.en),
      ),
      <String>['Flow', 'Connection', 'Creation', 'Courage', 'Balance'],
    );
  });

  test('her alan kendi saklanmış skoruyla baskın olabilir', () {
    for (final ExperienceDimension alan in ExperienceDimension.values) {
      final LuckResult kayit = sonuc(<LuckCategory, int>{
        for (final LuckCategory kategori in LuckCategory.values)
          kategori: kategori == alan.kategori ? 90 : 40,
      });
      expect(alan.skor(kayit), 90);
      expect(ExperienceDimension.baskinAlan(kayit), alan);
      expect(kayit.genelSkor, 60);
    }
  });

  test('eşitlik, map sırasından bağımsız olarak eski motor sırasını izler', () {
    // Her kategori çifti için daha önce tanımlanan motor kategorisi kazanır.
    // Ters map sırası, yanlışlıkla Map.entries üzerinden seçimi de yakalar.
    for (int i = 0; i < LuckCategory.values.length; i++) {
      for (int j = i + 1; j < LuckCategory.values.length; j++) {
        final LuckCategory ilk = LuckCategory.values[i];
        final LuckCategory ikinci = LuckCategory.values[j];
        for (final siralama in <Iterable<LuckCategory>>[
          LuckCategory.values,
          LuckCategory.values.reversed,
        ]) {
          final LuckResult kayit = sonuc(<LuckCategory, int>{
            for (final kategori in siralama)
              kategori: kategori == ilk || kategori == ikinci ? 80 : 30,
          });
          expect(
            ExperienceDimension.baskinAlan(kayit),
            ExperienceDimension.kategoriden(ilk),
          );
        }
      }
    }
    expect(
      ExperienceDimension.baskinAlan(
        sonuc(<LuckCategory, int>{
          for (final kategori in LuckCategory.values.reversed) kategori: 0,
        }),
      ),
      ExperienceDimension.bag,
    );
  });

  test('eksik skorlar sessizce sıfıra veya kısmi baskın alana dönüşmez', () {
    for (final LuckCategory eksik in LuckCategory.values) {
      final LuckResult kayit = sonuc(<LuckCategory, int>{
        for (final kategori in LuckCategory.values)
          if (kategori != eksik) kategori: 50,
      });
      expect(
        () => ExperienceDimension.kategoriden(eksik).skor(kayit),
        throwsStateError,
      );
      expect(() => ExperienceDimension.baskinAlan(kayit), throwsStateError);
    }
    expect(
      () => ExperienceDimension.baskinAlan(sonuc(<LuckCategory, int>{})),
      throwsStateError,
    );
  });
}
