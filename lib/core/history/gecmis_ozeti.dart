import '../content/content_config.dart';
import '../storage/daily_record.dart';
import 'history_analiz_config.dart';

/// Geçmiş kayıtlarından türetilen özet istatistikler (Phase 2).
///
/// Saf değer nesnesi: Flutter/Hive bilmez, `gecmisiOzetle` tarafından
/// deterministik üretilir. "Kanıt Döngüsü" alanları, kullanıcıya
/// gösterilen tahmin ↔ his korelasyonunu taşır.
class GecmisOzeti {
  /// Tüm alanlarıyla özet oluşturur.
  const GecmisOzeti({
    required this.toplamGun,
    required this.ortalamaSkor,
    required this.enSansliGun,
    required this.enSansliSkor,
    required this.kanitOrnekSayisi,
    required this.kanitPozitifSayisi,
    required this.kanitYuzdesi,
  });

  /// Hiç kayıt olmadığında kullanılan boş özet.
  static const GecmisOzeti bos = GecmisOzeti(
    toplamGun: 0,
    ortalamaSkor: 0,
    enSansliGun: null,
    enSansliSkor: null,
    kanitOrnekSayisi: 0,
    kanitPozitifSayisi: 0,
    kanitYuzdesi: null,
  );

  /// Toplam kayıtlı gün sayısı.
  final int toplamGun;

  /// Tüm günlerin ortalama genel skoru (boşta 0).
  final int ortalamaSkor;

  /// En yüksek skorlu günün tarihi (boşta null; eşitlikte en erken).
  final DateTime? enSansliGun;

  /// En yüksek skorlu günün skoru (boşta null).
  final int? enSansliSkor;

  /// Kanıt örneği: yüksek skorlu VE geri bildirimli gün sayısı (n).
  final int kanitOrnekSayisi;

  /// Kanıt örnekleri içinde kullanıcının da "şanslıydım" dediği gün sayısı.
  final int kanitPozitifSayisi;

  /// Kanıt yüzdesi; örnek sayısı eşiğin altındayken `null`.
  final int? kanitYuzdesi;

  /// Kanıt yüzdesi anlamlı mı? (yeterli örnek toplandı mı?)
  bool get kanitYeterli => kanitYuzdesi != null;
}

/// Bir günün "tahmini şanslı" (yüksek bant) sayılıp sayılmadığını döndürür.
///
/// `SkorBandi.bandiBul` yeniden kullanılır (heatmap renkleriyle aynı
/// kaynak); yani skor ≥ 60 (`yuksek`/`cokYuksek`) tahmini şanslıdır.
bool _tahminiSansli(int skor) {
  final SkorBandi band = SkorBandi.bandiBul(skor);
  return band == SkorBandi.yuksek || band == SkorBandi.cokYuksek;
}

/// [kayitlar]dan deterministik geçmiş özeti üretir (saf; I/O yok).
///
/// [enAzKanitGunu]: kanıt yüzdesinin gösterileceği en az örnek sayısı;
/// altındaysa [GecmisOzeti.kanitYuzdesi] `null` kalır ama örnek sayısı
/// yine raporlanır ("şu ana kadar n"). Boş liste → [GecmisOzeti.bos].
GecmisOzeti gecmisiOzetle(
  List<DailyRecord> kayitlar, {
  int enAzKanitGunu = HistoryAnalizConfig.enAzKanitGunu,
}) {
  if (kayitlar.isEmpty) {
    return GecmisOzeti.bos;
  }

  int skorToplami = 0;
  DateTime enSansliGun = kayitlar.first.gun;
  int enSansliSkor = kayitlar.first.sonuc.genelSkor;
  int kanitOrnek = 0;
  int kanitPozitif = 0;

  for (final DailyRecord kayit in kayitlar) {
    final int skor = kayit.sonuc.genelSkor;
    skorToplami += skor;

    // En şanslı gün: yüksek skor kazanır; eşitlikte en erken gün kalır
    // (sıra-bağımsız determinizm).
    if (skor > enSansliSkor ||
        (skor == enSansliSkor && kayit.gun.isBefore(enSansliGun))) {
      enSansliSkor = skor;
      enSansliGun = kayit.gun;
    }

    // Kanıt kümesi: tahmini şanslı VE geri bildirim verilmiş günler.
    if (_tahminiSansli(skor) && kayit.feedbackPozitif != null) {
      kanitOrnek++;
      if (kayit.feedbackPozitif ?? false) {
        kanitPozitif++;
      }
    }
  }

  // Sıfıra bölme yok: yüzde ancak yeterli örnek varken hesaplanır.
  final int? kanitYuzdesi = kanitOrnek < enAzKanitGunu
      ? null
      : (kanitPozitif * 100 / kanitOrnek).round();

  return GecmisOzeti(
    toplamGun: kayitlar.length,
    ortalamaSkor: (skorToplami / kayitlar.length).round(),
    enSansliGun: enSansliGun,
    enSansliSkor: enSansliSkor,
    kanitOrnekSayisi: kanitOrnek,
    kanitPozitifSayisi: kanitPozitif,
    kanitYuzdesi: kanitYuzdesi,
  );
}
