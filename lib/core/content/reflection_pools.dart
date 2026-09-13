import '../localization/app_dil.dart';
import 'content_config.dart';
import 'experience_dimension.dart';
import 'localized_text.dart';

/// Eski günlük ve detay yorumlarını besleyen, geleceğe dair vaat içermeyen metinler.
abstract final class ReflectionPools {
  /// Her alan için altı bağımsız düşünme daveti.
  static const Map<ExperienceDimension, List<LocalizedText>> byDimension = {
    ExperienceDimension.akis: [
      LocalizedText(
        'Gündelik ayrıntılar başka bir bakışa yer açabilir.',
        'Everyday details can leave room for another perspective.',
      ),
      LocalizedText(
        'Kendi temponu fark etmek için kısa bir durak seçebilirsin.',
        'You can choose a brief pause to notice your own pace.',
      ),
      LocalizedText(
        'Tanıdık bir ortamda yeni bir ayrıntıya bakabilirsin.',
        'You can look for a new detail in a familiar place.',
      ),
      LocalizedText(
        'Planında küçük bir esneklik alanı bırakabilirsin.',
        'You can leave a little flexibility in your plan.',
      ),
      LocalizedText(
        'Bir karşılaşmadan kalan duyguyu merak edebilirsin.',
        'You can be curious about how an encounter left you feeling.',
      ),
      LocalizedText(
        'Sıradan bir an da dikkatini hak edebilir.',
        'An ordinary moment can deserve your attention too.',
      ),
    ],
    ExperienceDimension.bag: [
      LocalizedText(
        'Dinlemek, bir sohbete ayırabileceğin küçük bir alan olabilir.',
        'Listening can be a small space you make for a conversation.',
      ),
      LocalizedText(
        'Yakınlık bazen sade bir teşekkürle ifade edilebilir.',
        'Closeness can sometimes be expressed with a simple thank you.',
      ),
      LocalizedText(
        'Bir ilişkide kendi sınırlarına da yer verebilirsin.',
        'You can make room for your own boundaries in a relationship.',
      ),
      LocalizedText(
        'Bir mesajı hemen yanıtlamak zorunda değilsin.',
        'You do not have to reply to a message immediately.',
      ),
      LocalizedText(
        'Anlaşılmayan bir sözü yeniden sormak mümkün.',
        'It is possible to ask again about a remark you did not understand.',
      ),
      LocalizedText(
        'Birlikte yaşanan küçük bir anıyı hatırlayabilirsin.',
        'You can recall a small moment you shared with someone.',
      ),
    ],
    ExperienceDimension.uretim: [
      LocalizedText(
        'Bir fikrin ilk taslağı eksik kalabilir.',
        'The first draft of an idea can be incomplete.',
      ),
      LocalizedText(
        'Büyük bir işi küçük parçalara ayırabilirsin.',
        'You can break a large task into smaller pieces.',
      ),
      LocalizedText(
        'Tamamlanan küçük bir adımı görünür kılabilirsin.',
        'You can make a small completed step visible.',
      ),
      LocalizedText(
        'Odaklanmak için tek bir ayrıntı seçebilirsin.',
        'You can choose one detail to focus on.',
      ),
      LocalizedText(
        'Bir işe kendi bitiş ölçünü koyabilirsin.',
        'You can set your own finishing point for a task.',
      ),
      LocalizedText(
        'Yeni bir fikir önce kısa bir not olarak kalabilir.',
        'A new idea can start as a short note.',
      ),
    ],
    ExperienceDimension.cesaret: [
      LocalizedText(
        'Küçük bir denemenin kusursuz olması gerekmiyor.',
        'A small attempt does not need to be perfect.',
      ),
      LocalizedText(
        'Bir soruyu önce kendine prova edebilirsin.',
        'You can rehearse a question to yourself first.',
      ),
      LocalizedText(
        'Merak ettiğin bir fikre kısa bir süre ayırabilirsin.',
        'You can spend a little time on an idea you are curious about.',
      ),
      LocalizedText(
        'Bir başlangıcın boyutunu kendin seçebilirsin.',
        'You can choose the size of a beginning.',
      ),
      LocalizedText(
        'Bir taslağı paylaşmadan da deneyebilirsin.',
        'You can try a draft without sharing it.',
      ),
      LocalizedText(
        'Yeni bir şey denerken durmayı seçmek de mümkün.',
        'Choosing to stop is also possible when trying something new.',
      ),
    ],
    ExperienceDimension.denge: [
      LocalizedText(
        'Kendi ritmine yer ayırabilirsin.',
        'You can make room for your own rhythm.',
      ),
      LocalizedText(
        'Bir mola için her şeyi bitirmiş olman gerekmiyor.',
        'You do not need to finish everything before taking a break.',
      ),
      LocalizedText(
        'Kişisel bir planın kapsamını küçültebilirsin.',
        'You can reduce the scope of a personal plan.',
      ),
      LocalizedText(
        'Bugün yeterli olanı kendi ölçünle tanımlayabilirsin.',
        'You can define what is enough today on your own terms.',
      ),
      LocalizedText(
        'Beklentiler arasında kendine ait bir alan bırakabilirsin.',
        'You can leave some space for yourself among expectations.',
      ),
      LocalizedText(
        'Kısa bir durakta nasıl hissettiğini fark edebilirsin.',
        'You can notice how you feel during a brief pause.',
      ),
    ],
  };

  /// Skor bandı yalnız kartın davet tonunu değiştirir; gerçek günü tanımlamaz.
  static List<String> forTone(
    ExperienceDimension dimension,
    KategoriTonu tone,
    AppDil dil,
  ) {
    final String introduction = switch (tone) {
      KategoriTonu.dusuk => dil.sec(
        'Kartın bu temasına yavaşça yaklaşabilirsin',
        'You can approach this card theme slowly',
      ),
      KategoriTonu.orta => dil.sec(
        'Kartın bu temasını günlük bir ayrıntıyla keşfedebilirsin',
        'You can explore this card theme through an everyday detail',
      ),
      KategoriTonu.yuksek => dil.sec(
        'Kartın bu temasını küçük bir denemeye çevirebilirsin',
        'You can turn this card theme into a small experiment',
      ),
    };
    return List.unmodifiable(
      byDimension[dimension]!.map((LocalizedText pair) {
        final String text = pair.text(dil);
        return '$introduction; ${text[0].toLowerCase()}${text.substring(1)}';
      }),
    );
  }
}
