import '../luck_engine/luck_engine.dart';
import 'luck_result_mapper.dart';

/// Akşamın üç seçenekli, tahmin doğruluğu iddiası taşımayan geri bildirimi.
enum FeedbackMood {
  /// İyi aktı.
  positive,

  /// Karışıktı.
  neutral,

  /// Zorlayıcıydı.
  difficult,
}

/// Saklanmış motor sonucu, kart açılışı ve isteğe bağlı akşam geri bildirimi.
class DailyRecord {
  /// Eski bool girdisi geçiş ekranları için desteklenir; yeni mood önceliklidir.
  DailyRecord({
    required this.sonuc,
    this.revealedAt,
    FeedbackMood? feedbackMood,
    bool? feedbackPozitif,
    this.feedbackEmoji,
    List<String> feedbackTags = const <String>[],
  }) : feedbackMood = feedbackMood ?? _eskiMood(feedbackPozitif),
       feedbackTags = List<String>.unmodifiable(feedbackTags);

  /// Eski map'leri yeniden yazmadan okur. Tanınmayan mood verisini silmek
  /// yerine hata verir; yeni anahtardaki açık null eski bool'a düşmez.
  factory DailyRecord.fromMap(Map<dynamic, dynamic> map) {
    try {
      final Object? mood = map['feedbackMood'];
      FeedbackMood? parsedMood;
      if (mood != null) {
        for (final FeedbackMood value in FeedbackMood.values) {
          if (value.name == mood) parsedMood = value;
        }
        if (parsedMood == null) {
          throw const FormatException('Geri bildirim durumu desteklenmiyor.');
        }
      }
      return DailyRecord(
        sonuc: LuckResultMapper.fromMap(map['sonuc'] as Map<dynamic, dynamic>),
        revealedAt: map['revealedAt'] == null
            ? null
            : DateTime.parse(map['revealedAt'] as String),
        feedbackMood: parsedMood,
        feedbackPozitif: map.containsKey('feedbackMood')
            ? null
            : map['feedbackPozitif'] as bool?,
        feedbackEmoji: map['feedbackEmoji'] as String?,
        feedbackTags:
            (map['feedbackTags'] as List<dynamic>? ?? const <dynamic>[])
                .cast<String>(),
      );
    } on TypeError {
      throw const FormatException(
        'Günlük kaydın alan türleri geçersiz; kayıt değiştirilmedi.',
      );
    } on ArgumentError {
      throw const FormatException(
        'Günlük kaydın kategori kimliği geçersiz; kayıt değiştirilmedi.',
      );
    } on FormatException {
      throw const FormatException(
        'Günlük kaydın tarih veya feedback bilgisi geçersiz; kayıt değiştirilmedi.',
      );
    }
  }

  static const Object _degismedi = Object();

  static FeedbackMood? _eskiMood(bool? value) => value == null
      ? null
      : value
      ? FeedbackMood.positive
      : FeedbackMood.difficult;

  /// Motorun orijinal sonucu; migration sırasında yeniden hesaplanmaz.
  final LuckResult sonuc;

  /// Kullanıcının kartı ilk açtığı zaman; null ise henüz açılmamıştır.
  final DateTime? revealedAt;

  /// Kullanıcının gün değerlendirmesi; null ise henüz yanıt yoktur.
  final FeedbackMood? feedbackMood;

  /// Seçilen alanların sabit kimlikleri; boş liste geçerli bir seçimdir.
  final List<String> feedbackTags;

  /// Eski arayüzün opsiyonel emojisi; yeni akışa geçişte korunur.
  final String? feedbackEmoji;

  /// Eski iki seçenekli tüketiciler için adapter. Nötr yanıt zorlayıcı
  /// sayılmaz; yanıtın varlığı için [feedbackMood] kontrol edilmelidir.
  bool? get feedbackPozitif => switch (feedbackMood) {
    FeedbackMood.positive => true,
    FeedbackMood.difficult => false,
    FeedbackMood.neutral || null => null,
  };

  /// Kaydın ait olduğu gün.
  DateTime get gun => sonuc.gun;

  /// Geriye uyumlu bool dahil Hive gösterimi; nötr değer bool'a sıkıştırılmaz.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'sonuc': LuckResultMapper.toMap(sonuc),
    'revealedAt': revealedAt?.toIso8601String(),
    'feedbackMood': feedbackMood?.name,
    'feedbackTags': List<String>.of(feedbackTags),
    'feedbackPozitif': feedbackPozitif,
    'feedbackEmoji': feedbackEmoji,
  };

  /// Atlanan alanları korur; nullable alanları açık null ile temizler.
  /// İki feedback parametresi verilirse yeni [feedbackMood] önceliklidir.
  DailyRecord copyWith({
    Object? revealedAt = _degismedi,
    Object? feedbackMood = _degismedi,
    Object? feedbackPozitif = _degismedi,
    Object? feedbackEmoji = _degismedi,
    List<String>? feedbackTags,
  }) => DailyRecord(
    sonuc: sonuc,
    revealedAt: identical(revealedAt, _degismedi)
        ? this.revealedAt
        : revealedAt as DateTime?,
    feedbackMood: !identical(feedbackMood, _degismedi)
        ? feedbackMood as FeedbackMood?
        : !identical(feedbackPozitif, _degismedi)
        ? _eskiMood(feedbackPozitif as bool?)
        : this.feedbackMood,
    feedbackEmoji: identical(feedbackEmoji, _degismedi)
        ? this.feedbackEmoji
        : feedbackEmoji as String?,
    feedbackTags: feedbackTags ?? this.feedbackTags,
  );
}
