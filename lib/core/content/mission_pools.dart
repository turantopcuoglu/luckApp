import 'experience_dimension.dart';
import 'localized_text.dart';

/// İsteğe bağlı, kısa ve günlük bir eylem; tamamlanması skorları değiştirmez.
class MicroMission {
  /// Kalıcı içerik kimliği, alan ve iki dilde yönergesiyle görev oluşturur.
  const MicroMission({
    required this.id,
    required this.dimension,
    required this.instruction,
  });

  /// Dil ve liste sırasından bağımsız kimlik; mevcut kimlik yeniden kullanılmaz.
  final String id;

  /// Görevin bağlı olduğu deneyim alanı.
  final ExperienceDimension dimension;

  /// Türkçe ve İngilizce eylem yönergesi.
  final LocalizedText instruction;
}

/// Her alan için 20 görev; iki dil tek kayıtta ve aynı indeksle tutulur.
abstract final class MissionPools {
  /// Dönüşümlü gün grupları için en az 20 ve çift sayıda kayıt gerekir.
  static const int minimumPerDimension = 20;

  /// İçerik sürümü; seçim değişiklikleri bilinçli bir sürümle yapılır.
  static const String selectionVersion = 'mission_v1';

  /// Ardışık günler ayrı gruplar kullanır.
  static const int dayGroupCount = 2;

  /// Sabit sıradaki değiştirilemez görev havuzları.
  static const Map<ExperienceDimension, List<MicroMission>> byDimension = {
    ExperienceDimension.akis: [
      MicroMission(
        id: 'akis_01',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Bulunduğun yerde daha önce dikkat etmediğin üç ayrıntıyı fark et.',
          'Notice three details you had not seen in your surroundings.',
        ),
      ),
      MicroMission(
        id: 'akis_02',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Bulunduğun yerdeki sesleri yarım dakika boyunca dinle.',
          'Listen to the sounds around you for half a minute.',
        ),
      ),
      MicroMission(
        id: 'akis_03',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Günün için tek kelimelik bir tema seç.',
          'Choose a one-word theme for your day.',
        ),
      ),
      MicroMission(
        id: 'akis_04',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Bugün merak ettiğin küçük bir soruyu yaz.',
          'Write down one small question you are curious about today.',
        ),
      ),
      MicroMission(
        id: 'akis_05',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Çevrende aynı rengin üç farklı tonunu bul.',
          'Find three shades of the same color around you.',
        ),
      ),
      MicroMission(
        id: 'akis_06',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Tanıdık bir nesneyi bir dakika boyunca incele.',
          'Examine a familiar object for one minute.',
        ),
      ),
      MicroMission(
        id: 'akis_07',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Masandaki küçük bir nesnenin yerini değiştir.',
          'Move one small object on your desk.',
        ),
      ),
      MicroMission(
        id: 'akis_08',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'İki işin arasına bir dakikalık boşluk ayır.',
          'Leave a one-minute gap between two tasks.',
        ),
      ),
      MicroMission(
        id: 'akis_09',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Pencerenin dışındaki manzarayı üç kelimeyle tarif et.',
          'Describe the view outside your window in three words.',
        ),
      ),
      MicroMission(
        id: 'akis_10',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Bugün fark ettiğin hoş bir ayrıntıyı kendine not olarak kaydet.',
          'Save a pleasant detail you noticed today as a note to yourself.',
        ),
      ),
      MicroMission(
        id: 'akis_11',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Sıradan bir gününü güzelleştiren küçük bir anı hatırla.',
          'Recall a small moment that brightened an ordinary day.',
        ),
      ),
      MicroMission(
        id: 'akis_12',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Yakındaki bir yüzeye düşen ışığı kısa bir süre izle.',
          'Observe the light on a nearby surface for a moment.',
        ),
      ),
      MicroMission(
        id: 'akis_13',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Bugün için esnetebileceğin iki küçük planı listele.',
          'List two small plans you could keep flexible today.',
        ),
      ),
      MicroMission(
        id: 'akis_14',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Gününün şu ana kadarki temposunu tek bir çizgiyle çiz.',
          'Draw a single line showing the pace of your day so far.',
        ),
      ),
      MicroMission(
        id: 'akis_15',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Bugün tekrar bakmak istediğin bir ayrıntıyı seç.',
          'Choose one detail you would like to revisit today.',
        ),
      ),
      MicroMission(
        id: 'akis_16',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Her gün kullandığın bir nesnenin başka bir kullanımını düşün.',
          'Think of another use for an object you use every day.',
        ),
      ),
      MicroMission(
        id: 'akis_17',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Şu anki temponu sana ait bir kelimeyle adlandır.',
          'Name your current pace with a word of your own.',
        ),
      ),
      MicroMission(
        id: 'akis_18',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Yanındaki iki nesnenin dokusunu karşılaştır.',
          'Compare the textures of two objects beside you.',
        ),
      ),
      MicroMission(
        id: 'akis_19',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Bir dakika boyunca bulunduğun yerde değişen gölgeleri izle.',
          'Watch the changing shadows around you for one minute.',
        ),
      ),
      MicroMission(
        id: 'akis_20',
        dimension: ExperienceDimension.akis,
        instruction: LocalizedText(
          'Gününün küçük bir bölümünü kendine iki cümleyle anlat.',
          'Describe a small part of your day to yourself in two sentences.',
        ),
      ),
    ],
    ExperienceDimension.bag: [
      MicroMission(
        id: 'bag_01',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Güvendiğin birine kısa bir selam gönder.',
          'Send a short hello to someone you trust.',
        ),
      ),
      MicroMission(
        id: 'bag_02',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Bir arkadaşında takdir ettiğin tek bir özelliği yaz.',
          'Write down one quality you appreciate in a friend.',
        ),
      ),
      MicroMission(
        id: 'bag_03',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Tanıdığın birine küçük bir yardımı için teşekkür et.',
          'Thank someone you know for a small act of help.',
        ),
      ),
      MicroMission(
        id: 'bag_04',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Bir sonraki sohbetinde karşındakini sözünü kesmeden dinle.',
          'Listen until the other person finishes their sentence in your next chat.',
        ),
      ),
      MicroMission(
        id: 'bag_05',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Seni gülümseten ortak bir anıyı hatırla.',
          'Recall a shared memory that made you smile.',
        ),
      ),
      MicroMission(
        id: 'bag_06',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Yakın olduğun birine gününün nasıl geçtiğini sor.',
          'Ask someone close to you how their day has been.',
        ),
      ),
      MicroMission(
        id: 'bag_07',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Göndermek zorunda olmadığın nazik bir mesaj taslağı hazırla.',
          'Draft a kind message without feeling obliged to send it.',
        ),
      ),
      MicroMission(
        id: 'bag_08',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Tanıdığın biriyle sevdiğin bir şarkının adını paylaş.',
          'Share the name of a song you enjoy with someone you know.',
        ),
      ),
      MicroMission(
        id: 'bag_09',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Bir ilişkinde sana iyi gelen küçük bir davranışı not et.',
          'Note a small gesture you value in a relationship.',
        ),
      ),
      MicroMission(
        id: 'bag_10',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Sonraki sohbetinde sormak istediğin açık uçlu bir soruyu seç.',
          'Choose an open-ended question for your next conversation.',
        ),
      ),
      MicroMission(
        id: 'bag_11',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Bugün kendine söylemek istediğin nazik bir cümleyi yaz.',
          'Write a kind sentence you would like to say to yourself today.',
        ),
      ),
      MicroMission(
        id: 'bag_12',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Sana destek olan birinin yaptığı küçük bir şeyi hatırla.',
          'Recall a small thing someone did to support you.',
        ),
      ),
      MicroMission(
        id: 'bag_13',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Yakın olduğun birine içten bir teşekkür cümlesi gönder.',
          'Send a sincere sentence of thanks to someone close to you.',
        ),
      ),
      MicroMission(
        id: 'bag_14',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Bir sohbette farklı anladığın bir sözü yeniden sormanın yolunu düşün.',
          'Think of a way to ask about a remark you may have understood differently.',
        ),
      ),
      MicroMission(
        id: 'bag_15',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Yanında rahat hissettiğin insanlarda ortak iki özelliği listele.',
          'List two qualities shared by people you feel comfortable around.',
        ),
      ),
      MicroMission(
        id: 'bag_16',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Tanıdığın birinin mesajını dikkatle okumak için bir dakika ayır.',
          'Take one minute to read a message from someone you know carefully.',
        ),
      ),
      MicroMission(
        id: 'bag_17',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Uygun bir sohbette kendi tercihini nazik bir cümleyle belirt.',
          'State a preference politely in a suitable conversation.',
        ),
      ),
      MicroMission(
        id: 'bag_18',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Bir arkadaşınla yapmak isteyeceğin basit bir etkinliği yaz.',
          'Write down a simple activity you would enjoy with a friend.',
        ),
      ),
      MicroMission(
        id: 'bag_19',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Dinlendiğini hissettiğin bir konuşmayı anımsa.',
          'Remember a conversation in which you felt heard.',
        ),
      ),
      MicroMission(
        id: 'bag_20',
        dimension: ExperienceDimension.bag,
        instruction: LocalizedText(
          'Bugün birine gösterebileceğin küçük bir nezaketi seç.',
          'Choose a small act of kindness you could offer someone today.',
        ),
      ),
    ],
    ExperienceDimension.uretim: [
      MicroMission(
        id: 'uretim_01',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Masandaki tek bir şeyi yerine yerleştir.',
          'Put one item on your desk back where it belongs.',
        ),
      ),
      MicroMission(
        id: 'uretim_02',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bekleyen bir işin yalnızca ilk adımını yaz.',
          'Write only the first step of a pending task.',
        ),
      ),
      MicroMission(
        id: 'uretim_03',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'İki dakikada bitebilecek küçük bir işi tamamla.',
          'Finish a small task that takes two minutes.',
        ),
      ),
      MicroMission(
        id: 'uretim_04',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bir notundaki tek bir cümleyi sadeleştir.',
          'Simplify one sentence in a note.',
        ),
      ),
      MicroMission(
        id: 'uretim_05',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Üzerinde çalıştığın bir dosyayı anlaşılır biçimde adlandır.',
          'Give a file you are working on a clear name.',
        ),
      ),
      MicroMission(
        id: 'uretim_06',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Aklındaki bir fikrin kaba taslağını çiz.',
          'Sketch a rough outline of an idea.',
        ),
      ),
      MicroMission(
        id: 'uretim_07',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bir işi düşünmek için üç dakika ayır.',
          'Set aside three minutes to think about one task.',
        ),
      ),
      MicroMission(
        id: 'uretim_08',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bir fikrini anlatan üç anahtar kelimeyi listele.',
          'List three keywords that describe an idea.',
        ),
      ),
      MicroMission(
        id: 'uretim_09',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Notlarının içinden tek bir başlığı düzenle.',
          'Organize one heading in your notes.',
        ),
      ),
      MicroMission(
        id: 'uretim_10',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bugün bitirmek istediğin küçük ve somut bir parçayı seç.',
          'Choose one small, concrete piece of work to finish today.',
        ),
      ),
      MicroMission(
        id: 'uretim_11',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bir işe başlamak için hangi bilgiye ihtiyacın olduğunu yaz.',
          'Write down what information you need to begin a task.',
        ),
      ),
      MicroMission(
        id: 'uretim_12',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Gözünde büyüyen bir işi üç küçük adıma böl.',
          'Break a daunting task into three small steps.',
        ),
      ),
      MicroMission(
        id: 'uretim_13',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Tamamladığın bir işte beğendiğin tek bir ayrıntıyı incele.',
          'Review one detail you like in something you finished.',
        ),
      ),
      MicroMission(
        id: 'uretim_14',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bir fikirle ilgili notlarını tek bir yerde topla.',
          'Gather notes about one idea in a single place.',
        ),
      ),
      MicroMission(
        id: 'uretim_15',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Kişisel bir not için kısa bir başlık tasarla.',
          'Create a short title for a personal note.',
        ),
      ),
      MicroMission(
        id: 'uretim_16',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bir iş için yeterince iyi sayacağın küçük bir bitiş noktası belirle.',
          'Define a small finishing point you would consider good enough for a task.',
        ),
      ),
      MicroMission(
        id: 'uretim_17',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Sıradaki işin için gereken bir malzemeyi hazırla.',
          'Prepare one item you need for your next task.',
        ),
      ),
      MicroMission(
        id: 'uretim_18',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Öğrendiğin bir şeyi iki cümleyle özetle.',
          'Summarize something you learned in two sentences.',
        ),
      ),
      MicroMission(
        id: 'uretim_19',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Bir fikri anlatmak için farklı bir çizim dene.',
          'Try a different drawing to explain an idea.',
        ),
      ),
      MicroMission(
        id: 'uretim_20',
        dimension: ExperienceDimension.uretim,
        instruction: LocalizedText(
          'Listende tamamladığın bir adımı işaretle.',
          'Mark one completed step on your list.',
        ),
      ),
    ],
    ExperienceDimension.cesaret: [
      MicroMission(
        id: 'cesaret_01',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Bir kâğıda alışık olmadığın bir şekil çizmeyi dene.',
          'Try drawing an unfamiliar shape on paper.',
        ),
      ),
      MicroMission(
        id: 'cesaret_02',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Denemek istediğin küçük bir fikri yaz.',
          'Write down a small idea you would like to try.',
        ),
      ),
      MicroMission(
        id: 'cesaret_03',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Güvendiğin birine merak ettiğin basit bir soruyu sor.',
          'Ask someone you trust a simple question you are curious about.',
        ),
      ),
      MicroMission(
        id: 'cesaret_04',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Ertelediğin yaratıcı bir işin bir dakikalık taslağını başlat.',
          'Start a one-minute draft of a creative task you have put off.',
        ),
      ),
      MicroMission(
        id: 'cesaret_05',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Bir fikrini prova amacıyla kendine sesli olarak söyle.',
          'Say an idea aloud to yourself as a rehearsal.',
        ),
      ),
      MicroMission(
        id: 'cesaret_06',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Sonucu düzeltmeden küçük bir karalama çiz.',
          'Draw a small doodle without correcting it.',
        ),
      ),
      MicroMission(
        id: 'cesaret_07',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Alışık olduğun bir iş için zararsız küçük bir değişiklik seç.',
          'Choose a harmless small change to a familiar task.',
        ),
      ),
      MicroMission(
        id: 'cesaret_08',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Bir denemede öğrenmek istediğin tek bir şeyi yaz.',
          'Write down one thing you would like to learn from an attempt.',
        ),
      ),
      MicroMission(
        id: 'cesaret_09',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Bir sorunu sormak için kısa bir cümle hazırla.',
          'Prepare a short sentence to ask your question.',
        ),
      ),
      MicroMission(
        id: 'cesaret_10',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Boş bir sayfayı tek bir kelimeyle doldurmaya başla.',
          'Start filling a blank page with a single word.',
        ),
      ),
      MicroMission(
        id: 'cesaret_11',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Sevdiğin bir şarkıya farklı bir ritim tutmayı dene.',
          'Try tapping a different rhythm to a song you enjoy.',
        ),
      ),
      MicroMission(
        id: 'cesaret_12',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Kendi kullanacağın hayali bir nesneyi tasarla.',
          'Design an imaginary object you would use yourself.',
        ),
      ),
      MicroMission(
        id: 'cesaret_13',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Bir fikrin kusurlu kalmasına izin veren bir ilk taslak yaz.',
          'Write a first draft that lets an idea remain imperfect.',
        ),
      ),
      MicroMission(
        id: 'cesaret_14',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'İstersen güvendiğin biriyle küçük bir öneri paylaş.',
          'Share a small suggestion with someone you trust, if you want to.',
        ),
      ),
      MicroMission(
        id: 'cesaret_15',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Merak ettiğin ama henüz denemediğin iki yaratıcı uğraşı listele.',
          'List two creative activities you are curious about but have not tried.',
        ),
      ),
      MicroMission(
        id: 'cesaret_16',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Tanıdık bir hikâye için farklı bir başlık üret.',
          'Create a different title for a familiar story.',
        ),
      ),
      MicroMission(
        id: 'cesaret_17',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Bir fikrini yalnızca beş kelimeyle anlat.',
          'Describe an idea in just five words.',
        ),
      ),
      MicroMission(
        id: 'cesaret_18',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Kendi sınırını anlatan nazik bir cümleyi prova et.',
          'Rehearse a kind sentence that expresses a personal boundary.',
        ),
      ),
      MicroMission(
        id: 'cesaret_19',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Bugün başlayabileceğin iki dakikalık bir deneme seç.',
          'Choose a two-minute experiment you could start today.',
        ),
      ),
      MicroMission(
        id: 'cesaret_20',
        dimension: ExperienceDimension.cesaret,
        instruction: LocalizedText(
          'Bugün küçük de olsa başlattığın bir şeyi not al.',
          'Note something you started today, however small.',
        ),
      ),
    ],
    ExperienceDimension.denge: [
      MicroMission(
        id: 'denge_01',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Yaptığın işe yarım dakikalık bir ara ver.',
          'Take a half-minute break from what you are doing.',
        ),
      ),
      MicroMission(
        id: 'denge_02',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Bugün kendine ayırmak istediğin kısa bir zamanı yaz.',
          'Write down a short period you would like to keep for yourself today.',
        ),
      ),
      MicroMission(
        id: 'denge_03',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Kişisel yapılacaklar listendeki bir işin kapsamını azalt.',
          'Reduce the scope of one task on your personal list.',
        ),
      ),
      MicroMission(
        id: 'denge_04',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Şu anda rahatça tamamlayabileceğin tek bir işi seç.',
          'Choose one task you can comfortably complete right now.',
        ),
      ),
      MicroMission(
        id: 'denge_05',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Bulunduğun ortamda sevdiğin bir dokuyu fark et.',
          'Notice a texture you enjoy in your surroundings.',
        ),
      ),
      MicroMission(
        id: 'denge_06',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Günün iki bölümü arasına kısa bir mola koy.',
          'Leave a short pause between two parts of your day.',
        ),
      ),
      MicroMission(
        id: 'denge_07',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Bugün sana fazla gelen bir beklentiyi not et.',
          'Note one expectation that feels like too much today.',
        ),
      ),
      MicroMission(
        id: 'denge_08',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Dinlenmek için kullandığın yerde tek bir nesneyi düzenle.',
          'Arrange one object in a place where you like to rest.',
        ),
      ),
      MicroMission(
        id: 'denge_09',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Bugün yeterli sayabileceğin küçük bir sonucu yaz.',
          'Write down one small result that could be enough for today.',
        ),
      ),
      MicroMission(
        id: 'denge_10',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'İşini kaydet; artık kullanmadığın bir sekmeyi kapat.',
          'Close one unused tab after saving anything you need.',
        ),
      ),
      MicroMission(
        id: 'denge_11',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Kendi seçebildiğin iki küçük günlük tercihi listele.',
          'List two small everyday choices you can make for yourself.',
        ),
      ),
      MicroMission(
        id: 'denge_12',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Sevdiğin bir parçanın kısa bir bölümünü dinle.',
          'Listen to a short section of a piece of music you enjoy.',
        ),
      ),
      MicroMission(
        id: 'denge_13',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Sıradaki kişisel işine geçmeden önce yirmi saniye bekle.',
          'Wait twenty seconds before moving to your next personal task.',
        ),
      ),
      MicroMission(
        id: 'denge_14',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Kendi temponda geçirdiğin sakin bir anı hatırla.',
          'Recall an ordinary moment you spent at your own pace.',
        ),
      ),
      MicroMission(
        id: 'denge_15',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Bugün mola verebileceğin kısa bir aralığı belirle.',
          'Identify a short time when you could take a break today.',
        ),
      ),
      MicroMission(
        id: 'denge_16',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Kendine koyduğun bir hedefin ilk adımını sadeleştir.',
          'Simplify the first step of a goal you set for yourself.',
        ),
      ),
      MicroMission(
        id: 'denge_17',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Şu an ihtiyacın olan alanı tek bir cümleyle tanımla.',
          'Describe the space you need right now in one sentence.',
        ),
      ),
      MicroMission(
        id: 'denge_18',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Kişisel planında isteğe bağlı olan bir maddeyi incele.',
          'Review one optional item in your personal plan.',
        ),
      ),
      MicroMission(
        id: 'denge_19',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Bulunduğun yerde gözünü dinlendiren bir rengi seç.',
          'Choose a color around you that feels restful to look at.',
        ),
      ),
      MicroMission(
        id: 'denge_20',
        dimension: ExperienceDimension.denge,
        instruction: LocalizedText(
          'Gününü kapatırken kendine bırakmak istediğin kısa bir not yaz.',
          'Write a short note you would like to leave yourself at the end of the day.',
        ),
      ),
    ],
  };
}
