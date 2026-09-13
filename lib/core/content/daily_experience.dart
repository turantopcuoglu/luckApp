import 'daily_archetype.dart';
import 'experience_dimension.dart';

/// Bir alanın saklanmış skoru; UI erişim politikasını uygulamadan göstermez.
typedef DimensionScore = ({ExperienceDimension dimension, int score});

/// Saklanmış sonuçtan türetilen değiştirilemez günlük içerik görünümü.
/// Ham skorlar içerir; paylaşım, semantics ve kilit maskesi UI sorumluluğudur.
class DailyExperience {
  /// Günlük içeriği oluşturur; sıralı alanların savunmacı kopyasını alır.
  DailyExperience({
    required this.date,
    required this.score,
    required this.archetype,
    required List<DimensionScore> orderedDimensions,
    required this.microMissionId,
    required this.microMission,
    required this.shortReflection,
  }) : orderedDimensions = List.unmodifiable(orderedDimensions);

  /// Sonucun ait olduğu yerel takvim günü.
  final DateTime date;

  /// Yeniden hesaplanmadan okunan genel skor.
  final int score;

  /// Baskın alana bağlı kart teması.
  final DailyArchetype archetype;

  /// Günün baskın deneyim alanı.
  ExperienceDimension get dominantDimension => archetype.dimension;

  /// UI gösterim sırasındaki alanlar ve ham skorları.
  final List<DimensionScore> orderedDimensions;

  /// Dil değişiminde korunan görev kimliği.
  final String microMissionId;

  /// Aktif dildeki isteğe bağlı eylem.
  final String microMission;

  /// Aktif dildeki kısa düşünme daveti.
  final String shortReflection;

  /// Üretim arketip illüstrasyonunun kimliği.
  String get illustrationId => archetype.illustrationId;

  /// İlk sürümde arketip başına tek kart görünümü bulunur.
  String get cardVariantId => illustrationId;

  @override
  bool operator ==(Object other) =>
      other is DailyExperience &&
      other.date == date &&
      other.score == score &&
      other.archetype == archetype &&
      other.microMissionId == microMissionId &&
      other.microMission == microMission &&
      other.shortReflection == shortReflection &&
      other.orderedDimensions.length == orderedDimensions.length &&
      Iterable<int>.generate(
        orderedDimensions.length,
      ).every((int i) => other.orderedDimensions[i] == orderedDimensions[i]);

  @override
  int get hashCode => Object.hash(
    date,
    score,
    archetype,
    microMissionId,
    microMission,
    shortReflection,
    Object.hashAll(orderedDimensions),
  );
}
