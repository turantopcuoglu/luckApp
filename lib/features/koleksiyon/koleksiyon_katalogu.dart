import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_images.dart';

/// Koleksiyondaki tek bir kart: kimlik, ad, kısa söz ve görsel.
class KoleksiyonKarti {
  /// [id] kimlikli kart (metinleri ARB'deki `koleksiyonKart*` anahtarları).
  const KoleksiyonKarti(this.id);

  /// Kalıcı kimlik: depolamada ve görsel dosya adında kullanılır; dilden
  /// bağımsızdır.
  final String id;

  /// Kartın [l] dilindeki adı.
  String ad(AppLocalizations l) => _metinler(l).$1;

  /// Kartın [l] dilindeki kısa sözü.
  String soz(AppLocalizations l) => _metinler(l).$2;

  /// Kimliğe göre (ad, söz) çifti. Katalogda olmayan kimlik bir
  /// programlama hatasıdır.
  (String, String) _metinler(AppLocalizations l) => switch (id) {
      'hilal_kemer' => (l.koleksiyonKartHilalKemerAd, l.koleksiyonKartHilalKemerSoz),
      'isik_kapisi' => (l.koleksiyonKartIsikKapisiAd, l.koleksiyonKartIsikKapisiSoz),
      'mor_gece' => (l.koleksiyonKartMorGeceAd, l.koleksiyonKartMorGeceSoz),
      'acik_kapi' => (l.koleksiyonKartAcikKapiAd, l.koleksiyonKartAcikKapiSoz),
      'hilal_yildiz' => (l.koleksiyonKartHilalYildizAd, l.koleksiyonKartHilalYildizSoz),
      'kopruler' => (l.koleksiyonKartKoprulerAd, l.koleksiyonKartKoprulerSoz),
      'cam_fanus' => (l.koleksiyonKartCamFanusAd, l.koleksiyonKartCamFanusSoz),
      'kagit_ucak' => (l.koleksiyonKartKagitUcakAd, l.koleksiyonKartKagitUcakSoz),
      'tas_kule' => (l.koleksiyonKartTasKuleAd, l.koleksiyonKartTasKuleSoz),
      'dag_yolu' => (l.koleksiyonKartDagYoluAd, l.koleksiyonKartDagYoluSoz),
      'sonsuzluk' => (l.koleksiyonKartSonsuzlukAd, l.koleksiyonKartSonsuzlukSoz),
      'tas_kopru' => (l.koleksiyonKartTasKopruAd, l.koleksiyonKartTasKopruSoz),
      'dolunay' => (l.koleksiyonKartDolunayAd, l.koleksiyonKartDolunaySoz),
      'teras' => (l.koleksiyonKartTerasAd, l.koleksiyonKartTerasSoz),
      'isik_yolu' => (l.koleksiyonKartIsikYoluAd, l.koleksiyonKartIsikYoluSoz),
      'yildiz_yolu' => (l.koleksiyonKartYildizYoluAd, l.koleksiyonKartYildizYoluSoz),
      'acik_pencere' => (l.koleksiyonKartAcikPencereAd, l.koleksiyonKartAcikPencereSoz),
      'yuzen_fener' => (l.koleksiyonKartYuzenFenerAd, l.koleksiyonKartYuzenFenerSoz),
      'kum_saati' => (l.koleksiyonKartKumSaatiAd, l.koleksiyonKartKumSaatiSoz),
      'altin_tuy' => (l.koleksiyonKartAltinTuyAd, l.koleksiyonKartAltinTuySoz),
      'cam_merdiven' => (l.koleksiyonKartCamMerdivenAd, l.koleksiyonKartCamMerdivenSoz),
      'yildiz_cesmesi' => (l.koleksiyonKartYildizCesmesiAd, l.koleksiyonKartYildizCesmesiSoz),
      'ay_salincagi' => (l.koleksiyonKartAySalincagiAd, l.koleksiyonKartAySalincagiSoz),
      'pusula' => (l.koleksiyonKartPusulaAd, l.koleksiyonKartPusulaSoz),
      _ => throw StateError('Katalogda olmayan kart: $id'),
    };

  /// Kart görselinin asset yolu.
  String get gorsel => AppImages.koleksiyonKarti(id);

  @override
  bool operator ==(Object other) => other is KoleksiyonKarti && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Koleksiyon kataloğu: 24 kart, sabit sırada.
///
/// SIRA DEĞİŞTİRİLMEZ: günün kartı motorda bu listenin indeksiyle seçilir
/// (`LuckEngine.gununKarti`); sıra değişirse kullanıcıların günlük kartları
/// kayar. Yeni kart yalnızca listenin SONUNA eklenir (motor döngüsü o gün
/// yeniden karılır; kazanılmış kartlar kimlikle saklandığı için korunur).
abstract final class KoleksiyonKatalogu {
  /// Tüm kartlar (sıralı).
  static const List<KoleksiyonKarti> kartlar = <KoleksiyonKarti>[
    KoleksiyonKarti('hilal_kemer'),
    KoleksiyonKarti('isik_kapisi'),
    KoleksiyonKarti('mor_gece'),
    KoleksiyonKarti('acik_kapi'),
    KoleksiyonKarti('hilal_yildiz'),
    KoleksiyonKarti('kopruler'),
    KoleksiyonKarti('cam_fanus'),
    KoleksiyonKarti('kagit_ucak'),
    KoleksiyonKarti('tas_kule'),
    KoleksiyonKarti('dag_yolu'),
    KoleksiyonKarti('sonsuzluk'),
    KoleksiyonKarti('tas_kopru'),
    KoleksiyonKarti('dolunay'),
    KoleksiyonKarti('teras'),
    KoleksiyonKarti('isik_yolu'),
    KoleksiyonKarti('yildiz_yolu'),
    KoleksiyonKarti('acik_pencere'),
    KoleksiyonKarti('yuzen_fener'),
    KoleksiyonKarti('kum_saati'),
    KoleksiyonKarti('altin_tuy'),
    KoleksiyonKarti('cam_merdiven'),
    KoleksiyonKarti('yildiz_cesmesi'),
    KoleksiyonKarti('ay_salincagi'),
    KoleksiyonKarti('pusula'),
  ];

  /// [id] kimlikli kart (katalogda yoksa null).
  static KoleksiyonKarti? bul(String id) {
    for (final KoleksiyonKarti k in kartlar) {
      if (k.id == id) {
        return k;
      }
    }
    return null;
  }
}
