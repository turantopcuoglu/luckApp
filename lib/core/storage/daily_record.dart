import '../luck_engine/luck_engine.dart';
import 'luck_result_mapper.dart';

/// Bir günün tam kaydı: motor sonucu + kullanıcının o güne dair geri
/// bildirimleri ve reklamla açtığı kilitler.
///
/// daily_records kutusunda gün anahtarıyla saklanır. Sonradan eklenen
/// alanlar opsiyoneldir; eski kayıtlar sorunsuz okunur.
class DailyRecord {
  /// [sonuc] zorunlu, diğer alanlar opsiyoneldir.
  const DailyRecord({
    required this.sonuc,
    this.feedbackPozitif,
    this.feedbackEmoji,
    this.bolumGeriBildirimleri = const <String, bool>{},
    this.reklamKilitleri = const <String>{},
  });

  /// Hive'dan okunan map'ten kayıt kurar.
  factory DailyRecord.fromMap(Map<dynamic, dynamic> map) {
    final Map<dynamic, dynamic>? bolumler =
        map[_bolumAnahtari] as Map<dynamic, dynamic>?;
    final List<dynamic>? kilitler = map[_kilitAnahtari] as List<dynamic>?;
    return DailyRecord(
      sonuc: LuckResultMapper.fromMap(
        map[_sonucAnahtari] as Map<dynamic, dynamic>,
      ),
      feedbackPozitif: map[_feedbackPozitifAnahtari] as bool?,
      feedbackEmoji: map[_feedbackEmojiAnahtari] as String?,
      bolumGeriBildirimleri: <String, bool>{
        if (bolumler != null)
          for (final MapEntry<dynamic, dynamic> e in bolumler.entries)
            e.key as String: e.value as bool,
      },
      reklamKilitleri: <String>{
        if (kilitler != null)
          for (final dynamic k in kilitler) k as String,
      },
    );
  }

  static const String _sonucAnahtari = 'sonuc';
  static const String _feedbackPozitifAnahtari = 'feedbackPozitif';
  static const String _feedbackEmojiAnahtari = 'feedbackEmoji';
  static const String _bolumAnahtari = 'bolumGeriBildirimleri';
  static const String _kilitAnahtari = 'reklamKilitleri';

  /// Günün motor sonucu.
  final LuckResult sonuc;

  /// Akşam geri bildirimi: gün gerçekten şanslı mıydı? (null = verilmedi).
  final bool? feedbackPozitif;

  /// Opsiyonel feedback emojisi.
  final String? feedbackEmoji;

  /// Okuma bölümlerine verilen "beni anlattı mı?" cevapları
  /// (bölüm kimliği → true: anlattı, false: anlatmadı).
  final Map<String, bool> bolumGeriBildirimleri;

  /// O gün ödüllü reklamla açılan içerik anahtarları.
  final Set<String> reklamKilitleri;

  /// Kaydın ait olduğu gün.
  DateTime get gun => sonuc.gun;

  /// Hive'a yazılacak map gösterimi.
  Map<String, dynamic> toMap() => <String, dynamic>{
        _sonucAnahtari: LuckResultMapper.toMap(sonuc),
        _feedbackPozitifAnahtari: feedbackPozitif,
        _feedbackEmojiAnahtari: feedbackEmoji,
        _bolumAnahtari: bolumGeriBildirimleri,
        _kilitAnahtari: reklamKilitleri.toList(),
      };

  /// Seçili alanları güncellenmiş bir kopya döndürür.
  DailyRecord copyWith({
    bool? feedbackPozitif,
    String? feedbackEmoji,
    Map<String, bool>? bolumGeriBildirimleri,
    Set<String>? reklamKilitleri,
  }) =>
      DailyRecord(
        sonuc: sonuc,
        feedbackPozitif: feedbackPozitif ?? this.feedbackPozitif,
        feedbackEmoji: feedbackEmoji ?? this.feedbackEmoji,
        bolumGeriBildirimleri:
            bolumGeriBildirimleri ?? this.bolumGeriBildirimleri,
        reklamKilitleri: reklamKilitleri ?? this.reklamKilitleri,
      );
}
