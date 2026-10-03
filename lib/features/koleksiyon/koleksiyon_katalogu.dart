import '../../shared/widgets/app_images.dart';
import 'koleksiyon_strings.dart';

/// Koleksiyondaki tek bir kart: kimlik, ad, kısa söz ve görsel.
class KoleksiyonKarti {
  /// [id] kimlikli kart (metinleri [KoleksiyonStrings.kartlar]'dan gelir).
  const KoleksiyonKarti(this.id);

  /// Kalıcı kimlik: depolamada ve görsel dosya adında kullanılır.
  final String id;

  /// Kartın adı.
  String get ad => KoleksiyonStrings.kartlar[id]!.$1;

  /// Kartın kısa sözü.
  String get soz => KoleksiyonStrings.kartlar[id]!.$2;

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
