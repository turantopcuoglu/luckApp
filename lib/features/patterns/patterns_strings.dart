import '../../core/content/rare_sign_id.dart';
import '../../core/history/patterns_config.dart';
import '../../core/history/patterns_summary.dart';
import '../../core/history/rare_sign_progress.dart';
import '../../core/localization/app_dil.dart';

/// Desen verisini tahmin doğruluğu veya nedensellik iddiası olmadan açıklar.
abstract final class PatternsStrings {
  /// Son 30 gün ile tüm geçmişin kapsamını açıkça ayırır.
  static String participation(PatternsSummary summary, AppDil language) {
    final int recent = summary.rhythm
        .where((RhythmDay day) => day.participated)
        .length;
    if (summary.participationDays == 0) {
      return language.sec(
        'İlk kartını açtığında kendi ritmin burada görünmeye başlayacak.',
        'Your rhythm will begin to appear here when you open your first card.',
      );
    }
    return language.sec(
      'Son ${PatternsConfig.rhythmDays} günde $recent gün katıldın. '
          'Tüm geçmişinde ${summary.participationDays} katılım günü var.',
      'You took part on $recent days in the last ${PatternsConfig.rhythmDays} '
          'days, and on ${summary.participationDays} days in your full history.',
    );
  }

  /// Seri yoksa kayıp, suçlama veya geri sayım dili kullanmaz.
  static String streak(PatternsSummary summary, AppDil language) =>
      summary.currentStreak == 0
      ? language.sec(
          'Ritmine istediğin zaman dönebilirsin; geçmişin burada kalır.',
          'Return at your own pace; your history stays here.',
        )
      : language.sec(
          'Şu anki ritminde ${summary.currentStreak} katılım günü var. '
              'Bir günlük aralar seriyi bozmaz ve sayıya eklenmez.',
          'Your current rhythm includes ${summary.currentStreak} days of '
              'participation. One-day breaks preserve it without adding days.',
        );

  /// Eşit sıklıktaki temaları birlikte gösterir; kişilik veya gelecek çıkarmaz.
  static String frequentThemes(PatternsSummary summary, AppDil language) {
    if (summary.mostFrequentArchetypes.isEmpty) {
      return language.sec(
        'Son ${PatternsConfig.rhythmDays} günde açılmış bir kart yok. '
            'Temalar kartlarını açtıkça burada birikir.',
        'No cards opened in the last ${PatternsConfig.rhythmDays} days. '
            'Themes collect here as you open your cards.',
      );
    }
    final String names = summary.mostFrequentArchetypes
        .map((value) => value.title(language))
        .join(', ');
    return language.sec(
      'Son ${PatternsConfig.rhythmDays} günde açtığın kartlarda en sık görünen '
          'temalar: $names. Bu, kart geçmişinin bir özeti.',
      'Most frequent themes in cards you opened in the last '
          '${PatternsConfig.rhythmDays} days: $names. '
          'This is a summary of your card history.',
    );
  }

  /// Yanıt sayıları görünürdür; eksik günler bir duyguya dönüştürülmez.
  static String feedbackTrend(FeedbackTrend trend, AppDil language) {
    final String description = switch (trend.direction) {
      FeedbackTrendDirection.insufficient => language.sec(
        'Karşılaştırma için her iki haftada en az '
            '${PatternsConfig.minimumTrendResponses} değerlendirme gerekir.',
        'Each week needs at least ${PatternsConfig.minimumTrendResponses} '
            'check-ins for a comparison.',
      ),
      FeedbackTrendDirection.morePositive => language.sec(
        'Son hafta yanıtların daha çok “İyi aktı” yönünde.',
        'Recent responses lean more toward “Flowed well”.',
      ),
      FeedbackTrendDirection.moreDifficult => language.sec(
        'Son hafta yanıtların daha çok “Zorlayıcıydı” yönünde.',
        'Recent responses lean more toward “Challenging”.',
      ),
      FeedbackTrendDirection.unchanged => language.sec(
        'İki haftadaki yanıt dağılımın aynı.',
        'Your response proportions are the same in both weeks.',
      ),
      FeedbackTrendDirection.mixed => language.sec(
        'Yanıt dağılımın değişmiş; tek bir yön öne çıkmıyor.',
        'Your response mix has changed, without a single direction.',
      ),
    };
    return language.sec(
      '$description Önceki hafta ${trend.previous.total}, son hafta '
          '${trend.recent.total} yanıt. Bu yalnızca senin değerlendirmelerin; '
          'kart skorlarının doğruluğunu ölçmez.',
      '$description ${trend.previous.total} responses in the previous week, '
          '${trend.recent.total} in the recent week. These are your check-ins, '
          'not a measure of card score accuracy.',
    );
  }

  /// Nadir kartın tasarım kataloğuyla eşleşen TR/EN başlığı.
  static String rareTitle(RareSignId id, AppDil language) => switch (id) {
    RareSignId.acikKapi => language.sec('Açık Kapı', 'Open Door'),
    RareSignId.kesisenYollar => language.sec(
      'Kesişen Yollar',
      'Crossing Paths',
    ),
    RareSignId.sessizTohum => language.sec('Sessiz Tohum', 'Quiet Seed'),
    RareSignId.ucanNot => language.sec('Uçan Not', 'Flying Note'),
    RareSignId.dengeliTas => language.sec('Dengeli Taş', 'Balanced Stone'),
    RareSignId.yeniPatika => language.sec('Yeni Patika', 'New Path'),
    RareSignId.geriDonenSerit => language.sec(
      'Geri Dönen Şerit',
      'Returning Ribbon',
    ),
    RareSignId.kucukKopru => language.sec('Küçük Köprü', 'Little Bridge'),
    RareSignId.acikPencere => language.sec('Açık Pencere', 'Open Window'),
    RareSignId.beklenmedikDurak => language.sec(
      'Beklenmedik Durak',
      'Unexpected Pause',
    ),
    RareSignId.yanYanaIzler => language.sec(
      'Yan Yana İzler',
      'Side-by-Side Trails',
    ),
    RareSignId.parlakYol => language.sec('Parlak Yol', 'Bright Path'),
  };

  /// Kilit sheet'inde gösterilecek tam koşul; hedefi modelden okur.
  static String rareCondition(
    RareSignProgress sign,
    AppDil language,
  ) => switch (sign.condition) {
    RareSignCondition.firstReveal => language.sec(
      'İlk günlük kartını aç.',
      'Open your first daily card.',
    ),
    RareSignCondition.feedbackDays => language.sec(
      '${sign.target} farklı gün için değerlendirme bırak.',
      'Leave check-ins for ${sign.target} different days.',
    ),
    RareSignCondition.participationDays => language.sec(
      '${sign.target} farklı günde kart aç veya değerlendirme bırak.',
      'Open a card or leave a check-in on ${sign.target} different days.',
    ),
    RareSignCondition.firstShare => language.sec(
      'İlk kartını paylaş. Doğrulanmış paylaşım kaydı gerekir.',
      'Share your first card. A verified share record is required.',
    ),
    RareSignCondition.returnAfterBreak => language.sec(
      'En az ${PatternsConfig.returnGapDays - 1} boş günden sonra yeniden katıl.',
      'Return after at least ${PatternsConfig.returnGapDays - 1} days away.',
    ),
    RareSignCondition.distinctArchetypes => language.sec(
      '${sign.target} farklı arketipin hepsinde bir kart aç.',
      'Open a card for each of the ${sign.target} archetypes.',
    ),
    RareSignCondition.brightCard => language.sec(
      'Genel skoru en az ${PatternsConfig.brightPathScore} olan bir kart aç.',
      'Open a card with an overall score of at least ${PatternsConfig.brightPathScore}.',
    ),
  };
}
