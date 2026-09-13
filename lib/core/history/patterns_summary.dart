import '../content/daily_archetype.dart';
import '../content/experience_dimension.dart';
import '../storage/daily_record.dart';
import 'rare_sign_progress.dart';

/// Bir takvim gününün ritim verisi; eksik gün olumsuz feedback değildir.
class RhythmDay {
  /// Saf analiz tarafından oluşturulur; skor ve kilitli alan değerleri içermez.
  const RhythmDay({
    required this.date,
    required this.participated,
    required this.cardOpened,
    required this.feedback,
    required this.archetype,
  });

  /// Saat dilimi dönüşümü yapılmamış yerel takvim tarihi.
  final DateTime date;

  /// Açılış veya değerlendirme kanıtı var mı?
  final bool participated;

  /// Gerçek açılış kaydı var mı? Eski feedback bunu varsaydırmaz.
  final bool cardOpened;

  /// Yanıt yoksa null; nötr yanıt da bağımsız bir durumdur.
  final FeedbackMood? feedback;

  /// Yalnız açılmış kartın teması; kapalı kartta null.
  final DailyArchetype? archetype;
}

/// Skordan bağımsız üç yanıtın ham sayıları; doğruluk yüzdesi üretmez.
class FeedbackDistribution {
  /// Tüm seçenekleri, hiç seçilmemiş olanlar dahil, korur.
  FeedbackDistribution(Iterable<FeedbackMood> moods) {
    final Map<FeedbackMood, int> counts = <FeedbackMood, int>{
      for (final FeedbackMood mood in FeedbackMood.values) mood: 0,
    };
    for (final FeedbackMood mood in moods) {
      counts[mood] = counts[mood]! + 1;
    }
    values = Map<FeedbackMood, int>.unmodifiable(counts);
  }

  /// Seçenek başına yanıt sayısı; değiştirilemez.
  late final Map<FeedbackMood, int> values;

  /// Değerlendirme yapılan gün sayısı; eksik günler paydaya girmez.
  int get total => values.values.fold(0, (int sum, int count) => sum + count);

  /// Belirli seçeneğin sayısı.
  int count(FeedbackMood mood) => values[mood]!;
}

/// İki haftadaki kişisel yanıt oranlarının betimleyici karşılaştırması.
enum FeedbackTrendDirection {
  /// En az bir haftada yeterli yanıt yok.
  insufficient,

  /// İyi aktı payı arttı veya zorlayıcı payı azaldı; diğeri tersine gitmedi.
  morePositive,

  /// Zorlayıcı payı arttı veya iyi aktı payı azaldı; diğeri tersine gitmedi.
  moreDifficult,

  /// Üç yanıtın oranları değişmedi.
  unchanged,

  /// İyi aktı ve zorlayıcı payları birlikte arttı veya birlikte azaldı.
  mixed,
}

/// Bugün dahil son 7 gün ile ondan önceki 7 gün; tahmin başarısı değildir.
class FeedbackTrend {
  /// Tarih aralıkları iki uç dahil olacak biçimde saklanır.
  const FeedbackTrend({
    required this.previousStart,
    required this.recentStart,
    required this.end,
    required this.previous,
    required this.recent,
    required this.direction,
  });

  /// Önceki haftanın ilk günü.
  final DateTime previousStart;

  /// Son haftanın ilk günü; önceki hafta bundan bir takvim günü önce biter.
  final DateTime recentStart;

  /// Son haftanın son günü.
  final DateTime end;

  /// Önceki hafta yanıtları.
  final FeedbackDistribution previous;

  /// Son hafta yanıtları.
  final FeedbackDistribution recent;

  /// Yalnız kullanıcının verdiği yanıtların yönü.
  final FeedbackTrendDirection direction;
}

/// Desenlerim ekranının değiştirilemez, UI bağımsız veri sözleşmesi.
class PatternsSummary {
  /// Koleksiyonlar savunmalı kopyalanır; girdiler sonradan değiştirilemez.
  PatternsSummary({
    required List<RhythmDay> rhythm,
    required this.feedback,
    required this.trend,
    required this.participationDays,
    required this.currentStreak,
    required this.longestStreak,
    required Map<DailyArchetype, int> archetypeCounts,
    required List<DailyArchetype> mostFrequentArchetypes,
    required List<RareSignProgress> rareSigns,
  }) : rhythm = List<RhythmDay>.unmodifiable(rhythm),
       archetypeCounts = Map<DailyArchetype, int>.unmodifiable(archetypeCounts),
       mostFrequentArchetypes = List<DailyArchetype>.unmodifiable(
         mostFrequentArchetypes,
       ),
       rareSigns = List<RareSignProgress>.unmodifiable(rareSigns);

  /// Son 30 gün, eskiden yeniye; boş günler de bulunur.
  final List<RhythmDay> rhythm;

  /// Son 30 günün feedback dağılımı.
  final FeedbackDistribution feedback;

  /// İki ardışık 7 günlük pencerenin karşılaştırması.
  final FeedbackTrend trend;

  /// Tüm geçmişteki benzersiz, kanıtlı katılım günleri.
  final int participationDays;

  /// En geç dün katılım varsa mevcut şefkatli serideki gerçek katılım sayısı.
  final int currentStreak;

  /// Tüm geçmişteki en uzun şefkatli seri; boş günler sayıya eklenmez.
  final int longestStreak;

  /// Son 30 günde açılmış kartların arketip sayıları; sıfırlar dahil.
  final Map<DailyArchetype, int> archetypeCounts;

  /// Eşitler birlikte enum sırasında sunulur; veri yoksa boş.
  final List<DailyArchetype> mostFrequentArchetypes;

  /// Arketiplerle bire bir eşleşen en sık alanlar; sayısal skor içermez.
  List<ExperienceDimension> get mostFrequentDimensions =>
      List<ExperienceDimension>.unmodifiable(
        mostFrequentArchetypes.map((DailyArchetype value) => value.dimension),
      );

  /// Sabit 12 kart; koşullar tüm geçmiş üzerinden hesaplanır.
  final List<RareSignProgress> rareSigns;

  /// En son koşulu sağlanan kart; aynı tarihte katalogda önce gelen seçilir.
  RareSignProgress? get latestRareSign {
    RareSignProgress? latest;
    for (final RareSignProgress sign in rareSigns) {
      final DateTime? date = sign.eligibleOn;
      if (date != null &&
          (latest == null || date.isAfter(latest.eligibleOn!))) {
        latest = sign;
      }
    }
    return latest;
  }
}
