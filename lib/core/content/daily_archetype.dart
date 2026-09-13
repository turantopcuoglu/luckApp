import '../localization/app_dil.dart';
import 'experience_dimension.dart';
import 'localized_text.dart';

/// Günlük kartın baskın alana bağlı tema ve illüstrasyon kimliği.
enum DailyArchetype {
  /// Akış Günü teması.
  akis(
    ExperienceDimension.akis,
    LocalizedText('Akış Günü', 'Flow Day'),
    LocalizedText(
      'Gündelik ayrıntılar başka bir bakışa yer açabilir.',
      'Everyday details can leave room for another perspective.',
    ),
  ),

  /// Bağ Günü teması.
  bag(
    ExperienceDimension.bag,
    LocalizedText('Bağ Günü', 'Connection Day'),
    LocalizedText(
      'Dinlemek, bir sohbete ayırabileceğin küçük bir alan olabilir.',
      'Listening can be a small space you make for a conversation.',
    ),
  ),

  /// Üretim Günü teması.
  uretim(
    ExperienceDimension.uretim,
    LocalizedText('Üretim Günü', 'Creation Day'),
    LocalizedText(
      'Bir fikrin ilk taslağı eksik kalabilir.',
      'The first draft of an idea can be incomplete.',
    ),
  ),

  /// Cesaret Günü teması.
  cesaret(
    ExperienceDimension.cesaret,
    LocalizedText('Cesaret Günü', 'Courage Day'),
    LocalizedText(
      'Küçük bir denemenin kusursuz olması gerekmiyor.',
      'A small attempt does not need to be perfect.',
    ),
  ),

  /// Denge Günü teması.
  denge(
    ExperienceDimension.denge,
    LocalizedText('Denge Günü', 'Balance Day'),
    LocalizedText(
      'Kendi ritmine yer ayırabilirsin.',
      'You can make room for your own rhythm.',
    ),
  );

  const DailyArchetype(this.dimension, this._title, this._reflection);

  /// Arketipin temsil ettiği deneyim alanı.
  final ExperienceDimension dimension;
  final LocalizedText _title;
  final LocalizedText _reflection;

  /// Yerelleştirilmiş kart başlığı.
  String title(AppDil dil) => _title.text(dil);

  /// Kehanet içermeyen kısa düşünme daveti.
  String reflection(AppDil dil) => _reflection.text(dil);

  /// Hazır arketip WebP'sinin uzantısız kimliği; dosya yolu UI katmanındadır.
  String get illustrationId => 'archetype_${dimension.name}';

  /// Alanın tek arketip karşılığı.
  static DailyArchetype forDimension(ExperienceDimension dimension) =>
      values.firstWhere(
        (DailyArchetype archetype) => archetype.dimension == dimension,
      );
}
