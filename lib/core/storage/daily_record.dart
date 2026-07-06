import '../luck_engine/luck_engine.dart';
import 'luck_result_mapper.dart';

/// Bir günün tam kaydı: motor sonucu + kullanıcının akşam geri bildirimi.
///
/// daily_records kutusunda gün anahtarıyla saklanır. Feedback alanları
/// Session 8'de doldurulacak; şimdiden modelde yer alır ki kutu şeması
/// sonradan değişmesin.
class DailyRecord {
  /// [sonuc] zorunlu, feedback alanları opsiyoneldir.
  const DailyRecord({
    required this.sonuc,
    this.feedbackPozitif,
    this.feedbackEmoji,
  });

  /// Hive'dan okunan map'ten kayıt kurar.
  factory DailyRecord.fromMap(Map<dynamic, dynamic> map) {
    return DailyRecord(
      sonuc: LuckResultMapper.fromMap(
        map[_sonucAnahtari] as Map<dynamic, dynamic>,
      ),
      feedbackPozitif: map[_feedbackPozitifAnahtari] as bool?,
      feedbackEmoji: map[_feedbackEmojiAnahtari] as String?,
    );
  }

  static const String _sonucAnahtari = 'sonuc';
  static const String _feedbackPozitifAnahtari = 'feedbackPozitif';
  static const String _feedbackEmojiAnahtari = 'feedbackEmoji';

  /// Günün motor sonucu.
  final LuckResult sonuc;

  /// Akşam geri bildirimi: gün gerçekten şanslı mıydı? (null = verilmedi).
  final bool? feedbackPozitif;

  /// Opsiyonel feedback emojisi.
  final String? feedbackEmoji;

  /// Kaydın ait olduğu gün.
  DateTime get gun => sonuc.gun;

  /// Hive'a yazılacak map gösterimi.
  Map<String, dynamic> toMap() => <String, dynamic>{
        _sonucAnahtari: LuckResultMapper.toMap(sonuc),
        _feedbackPozitifAnahtari: feedbackPozitif,
        _feedbackEmojiAnahtari: feedbackEmoji,
      };

  /// Feedback alanları güncellenmiş bir kopya döndürür.
  DailyRecord copyWith({bool? feedbackPozitif, String? feedbackEmoji}) =>
      DailyRecord(
        sonuc: sonuc,
        feedbackPozitif: feedbackPozitif ?? this.feedbackPozitif,
        feedbackEmoji: feedbackEmoji ?? this.feedbackEmoji,
      );
}
