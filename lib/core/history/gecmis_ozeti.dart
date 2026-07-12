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
    required this.guncelSeri,
    required this.enUzunSeri,
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
    guncelSeri: 0,
    enUzunSeri: 0,
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

  /// Bugüne (veya dün-toleransıyla) uzanan güncel kayıt serisi.
  ///
  /// Şefkatli: tek boş gün affedilir; iki ardışık boş gün seriyi bitirir.
  /// [bugun] verilmediyse hesaplanmaz (0).
  final int guncelSeri;

  /// Tüm geçmişteki en uzun kayıt serisi (kişisel rekor).
  final int enUzunSeri;

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

/// Bir tarihin saatten arındırılmış gün ordinalini döndürür
/// (`sabahMetni`'deki gün-numarası deseniyle aynı).
int _gunOrdinali(DateTime gun) =>
    DateTime(gun.year, gun.month, gun.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// İki kayıt arası boşluğun seriyi sürdürüp sürdürmediği: bitişik (1)
/// ya da tek boş gün (2) tolere edilir; iki+ boş gün (>=3) kırar.
bool _seriSurer(int fark) => fark <= 2;

/// [ordinaller] (artan, benzersiz) içindeki en uzun grace'li seriyi sayar.
int _enUzunSeriHesapla(List<int> ordinaller) {
  if (ordinaller.isEmpty) {
    return 0;
  }
  int enUzun = 1;
  int guncel = 1;
  for (int i = 1; i < ordinaller.length; i++) {
    if (_seriSurer(ordinaller[i] - ordinaller[i - 1])) {
      guncel++;
    } else {
      guncel = 1;
    }
    if (guncel > enUzun) {
      enUzun = guncel;
    }
  }
  return enUzun;
}

/// Bugüne (veya dün-toleransıyla) uzanan güncel seriyi sayar.
int _guncelSeriHesapla(List<int> ordinaller, DateTime? bugun) {
  if (bugun == null || ordinaller.isEmpty) {
    return 0;
  }
  final int bugunOrd = _gunOrdinali(bugun);
  // Gelecekli kayıtları yok say; bugüne kadar olanları al.
  final List<int> gecmis = ordinaller.where((int o) => o <= bugunOrd).toList();
  if (gecmis.isEmpty) {
    return 0;
  }
  final int enSon = gecmis.last;
  // Bugün-toleransı: en son kayıt bugün ya da dün değilse seri sönmüş.
  if (bugunOrd - enSon >= 2) {
    return 0;
  }
  int seri = 1;
  int onceki = enSon;
  for (int i = gecmis.length - 2; i >= 0; i--) {
    if (_seriSurer(onceki - gecmis[i])) {
      seri++;
      onceki = gecmis[i];
    } else {
      break;
    }
  }
  return seri;
}

/// [kayitlar]dan deterministik geçmiş özeti üretir (saf; I/O yok).
///
/// [enAzKanitGunu]: kanıt yüzdesinin gösterileceği en az örnek sayısı;
/// altındaysa [GecmisOzeti.kanitYuzdesi] `null` kalır ama örnek sayısı
/// yine raporlanır ("şu ana kadar n"). Boş liste → [GecmisOzeti.bos].
///
/// [bugun]: verilirse [GecmisOzeti.guncelSeri] hesaplanır (bugüne/düne
/// uzanan seri); verilmezse 0. [GecmisOzeti.enUzunSeri] her zaman üretilir.
GecmisOzeti gecmisiOzetle(
  List<DailyRecord> kayitlar, {
  int enAzKanitGunu = HistoryAnalizConfig.enAzKanitGunu,
  DateTime? bugun,
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

  // Seri: günleri benzersiz, artan ordinallere indirge (kayıtlar zaten
  // güne göre sıralı gelir ama savunmacı davranırız).
  final List<int> ordinaller =
      kayitlar.map((DailyRecord k) => _gunOrdinali(k.gun)).toSet().toList()
        ..sort();

  return GecmisOzeti(
    toplamGun: kayitlar.length,
    ortalamaSkor: (skorToplami / kayitlar.length).round(),
    enSansliGun: enSansliGun,
    enSansliSkor: enSansliSkor,
    kanitOrnekSayisi: kanitOrnek,
    kanitPozitifSayisi: kanitPozitif,
    kanitYuzdesi: kanitYuzdesi,
    guncelSeri: _guncelSeriHesapla(ordinaller, bugun),
    enUzunSeri: _enUzunSeriHesapla(ordinaller),
  );
}
