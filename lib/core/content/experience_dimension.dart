import '../localization/app_dil.dart';
import '../luck_engine/luck_category.dart';
import '../luck_engine/luck_result.dart';

/// Saklanmış motor kategorilerini yeni deneyim diline bağlayan saf eşleme.
///
/// Hive anahtarları ve motor sırası bu sunum modelinden bağımsız kalır.
enum ExperienceDimension {
  /// Tempo ve karşılaşmalar.
  akis(LuckCategory.sosyal, 'Akış', 'Flow'),

  /// Yakınlık ve iletişim.
  bag(LuckCategory.ask, 'Bağ', 'Connection'),

  /// Odak, fikir ve tamamlama.
  uretim(LuckCategory.para, 'Üretim', 'Creation'),

  /// Küçük adımlar ve inisiyatif.
  cesaret(LuckCategory.risk, 'Cesaret', 'Courage'),

  /// Dinlenme, sınırlar ve ritim.
  denge(LuckCategory.saglik, 'Denge', 'Balance');

  const ExperienceDimension(this.kategori, this._etiketTr, this._etiketEn);

  /// Eski kayıt ve motor sonucundaki karşılık; yeni Hive anahtarı değildir.
  final LuckCategory kategori;

  final String _etiketTr;
  final String _etiketEn;

  /// Ekranların kullanacağı sıra; baskın alanın eşitlik kuralını belirlemez.
  static const List<ExperienceDimension> gosterimSirasi = <ExperienceDimension>[
    akis,
    bag,
    uretim,
    cesaret,
    denge,
  ];

  /// Aktif dilde gösterilecek alan adı.
  String etiket(AppDil dil) => dil.sec(_etiketTr, _etiketEn);

  /// Eski kategorinin yeni deneyim alanını tek eşleme üzerinden bulur.
  static ExperienceDimension kategoriden(LuckCategory kategori) => values
      .firstWhere((ExperienceDimension alan) => alan.kategori == kategori);

  /// Saklanmış sonuçtan alan skorunu okur; eksik skoru sıfır olarak gizlemez.
  int skor(LuckResult sonuc) {
    final int? deger = sonuc.kategoriSkorlari[kategori];
    if (deger == null) {
      throw StateError('Deneyim alanı için kategori skoru eksik.');
    }
    return deger;
  }

  /// En yüksek skorlu alanı seçer; eşitlikte eski motor enum sırası kazanır.
  ///
  /// Map ekleme sırası ve ekran gösterim sırası seçimi etkilemez. Eksik
  /// kategori içeren sonuçlarda kısmi bir arketip üretmek yerine hata verir.
  static ExperienceDimension baskinAlan(LuckResult sonuc) {
    ExperienceDimension baskin = kategoriden(LuckCategory.values.first);
    int enYuksek = baskin.skor(sonuc);
    for (final LuckCategory kategori in LuckCategory.values.skip(1)) {
      final ExperienceDimension aday = kategoriden(kategori);
      final int adaySkor = aday.skor(sonuc);
      // Yalnız kesin üstünlükte değiştir: eşitlikte ilk motor kategorisi kalır.
      if (adaySkor > enYuksek) {
        baskin = aday;
        enYuksek = adaySkor;
      }
    }
    return baskin;
  }
}
