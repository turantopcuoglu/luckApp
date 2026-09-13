import '../localization/app_dil.dart';
import '../luck_engine/luck_category.dart';
import 'category_pools.dart';
import 'content_config.dart';
import 'localized_text.dart';
import 'mission_pools.dart';
import 'sans_rengi.dart';

/// Mevcut ekranlar için yeni ürün dilindeki iki dilli günlük metin havuzları.
/// API adları eski çağrıları korur; içerik kehanet veya sonuç vaadi içermez.
abstract final class FortunePools {
  /// Skor bandına bağlı, geleceği tarif etmeyen açılış davetleri.
  static Map<SkorBandi, List<String>> acilisCumleleri(AppDil dil) =>
      Map.unmodifiable({
        for (final entry in _openings.entries)
          entry.key: List<String>.unmodifiable(
            entry.value.map((LocalizedText text) => text.text(dil)),
          ),
      });

  /// Eski kategori kimlikleriyle erişilen deneyim alanı düşünme davetleri.
  static Map<LuckCategory, Map<KategoriTonu, List<String>>> ortaCumleleri(
    AppDil dil,
  ) => CategoryPools.kategoriAcilislari(dil);

  /// Banttan bağımsız, yargılamayan kapanışlar.
  static List<String> kapanisCumleleri(AppDil dil) =>
      List.unmodifiable(_closings.map((LocalizedText text) => text.text(dil)));

  /// Eski tavsiye alanını güvenli mikro görev havuzuyla besler.
  static List<String> gununTavsiyeleri(AppDil dil) => List.unmodifiable([
    for (final pool in MissionPools.byDimension.values)
      for (final mission in pool) mission.instruction.text(dil),
  ]);

  /// Eski renk yüzeyleri kaldırılana kadar korunan dekoratif renk havuzu.
  static const List<SansRengi> sansRenkleri = <SansRengi>[
    SansRengi(adTr: 'Gece Mavisi', adEn: 'Midnight Blue', hexArgb: 0xFF1B2A4A),
    SansRengi(adTr: 'Altın Sarısı', adEn: 'Golden Yellow', hexArgb: 0xFFF4C95D),
    SansRengi(
      adTr: 'Nar Kırmızısı',
      adEn: 'Pomegranate Red',
      hexArgb: 0xFFB23A48,
    ),
    SansRengi(
      adTr: 'Zümrüt Yeşili',
      adEn: 'Emerald Green',
      hexArgb: 0xFF2E8B57,
    ),
    SansRengi(
      adTr: 'Lavanta Moru',
      adEn: 'Lavender Purple',
      hexArgb: 0xFF8B7EC8,
    ),
    SansRengi(adTr: 'Gül Kurusu', adEn: 'Dusty Rose', hexArgb: 0xFFC08081),
    SansRengi(adTr: 'Turkuaz', adEn: 'Turquoise', hexArgb: 0xFF30B8B2),
    SansRengi(adTr: 'Kehribar', adEn: 'Amber', hexArgb: 0xFFDC9A3E),
    SansRengi(adTr: 'Fildişi', adEn: 'Ivory', hexArgb: 0xFFF5EFE0),
    SansRengi(adTr: 'Bakır', adEn: 'Copper', hexArgb: 0xFFB0653A),
    SansRengi(adTr: 'Orman Yeşili', adEn: 'Forest Green', hexArgb: 0xFF1F5C40),
    SansRengi(adTr: 'Lila', adEn: 'Lilac', hexArgb: 0xFFB79FD4),
    SansRengi(adTr: 'Mercan', adEn: 'Coral', hexArgb: 0xFFE9705F),
    SansRengi(adTr: 'Duman Grisi', adEn: 'Smoke Grey', hexArgb: 0xFF8C93A0),
    SansRengi(adTr: 'Safir', adEn: 'Sapphire', hexArgb: 0xFF2456A6),
    SansRengi(adTr: 'Krem', adEn: 'Cream', hexArgb: 0xFFE8E3D3),
  ];

  static const Map<SkorBandi, List<LocalizedText>> _openings = {
    SkorBandi.cokDusuk: [
      LocalizedText(
        'Bu kart, günün tamamını anlatmaz.',
        'This card does not describe your whole day.',
      ),
      LocalizedText(
        'Bugünkü düşük puan, nasıl hissedeceğine karar vermez.',
        'A low score today does not decide how you will feel.',
      ),
      LocalizedText(
        'Küçük bir başlangıç için yüksek puana ihtiyacın yok.',
        'You do not need a high score for a small beginning.',
      ),
      LocalizedText(
        'Bu kartı kendine alan açmak için bir davet sayabilirsin.',
        'You can treat this card as an invitation to make room for yourself.',
      ),
      LocalizedText(
        'Gününü tek bir sayıyla değerlendirmek zorunda değilsin.',
        'You do not have to judge your day by a single number.',
      ),
      LocalizedText(
        'Bugün kendinden büyük bir performans beklemek zorunda değilsin.',
        'You do not have to expect a big performance from yourself today.',
      ),
      LocalizedText(
        'Bu sayı bir oyun ayrıntısı, senin değerin değil.',
        'This number is part of a game, not a measure of your worth.',
      ),
      LocalizedText(
        'Kısa bir durak da bugünün parçası olabilir.',
        'A brief pause can be part of today too.',
      ),
      LocalizedText(
        'Kartın düşük puanını bir sınır olarak görmek zorunda değilsin.',
        'You do not have to see a low card score as a limit.',
      ),
    ],
    SkorBandi.dusuk: [
      LocalizedText(
        'Bu kartın daveti, küçük bir ayrıntıya yer ayırmak.',
        'This card invites you to make room for a small detail.',
      ),
      LocalizedText(
        'Bugün kendi hızında başlayabilirsin.',
        'You can begin at your own pace today.',
      ),
      LocalizedText(
        'Bir planı küçültmek de bir tercih olabilir.',
        'Making a plan smaller can be a choice too.',
      ),
      LocalizedText(
        'Kartın puanı, günün nasıl geçeceğini belirlemez.',
        'The card score does not determine how your day will go.',
      ),
      LocalizedText(
        'Küçük bir meraka ayıracak bir an seçebilirsin.',
        'You can choose a moment for a small curiosity.',
      ),
      LocalizedText(
        'Günün ritmini önce gözlemlemeyi deneyebilirsin.',
        'You can try observing the pace of your day first.',
      ),
      LocalizedText(
        'Bir şeyi hemen tamamlamak zorunda değilsin.',
        'You do not have to finish something immediately.',
      ),
      LocalizedText(
        'Bugün kendine daha sade bir başlangıç sunabilirsin.',
        'You can offer yourself a simpler start today.',
      ),
      LocalizedText(
        'Bu kartın yanında kendi deneyimine de yer var.',
        'There is room for your own experience alongside this card.',
      ),
    ],
    SkorBandi.orta: [
      LocalizedText(
        'Bugünün kartını küçük bir keşif daveti olarak okuyabilirsin.',
        'You can read this card as an invitation to a small discovery.',
      ),
      LocalizedText(
        'Sıradan bir günde de merak edecek bir ayrıntı bulunabilir.',
        'Even an ordinary day can hold a detail to be curious about.',
      ),
      LocalizedText(
        'Güne nasıl yaklaşacağını kendin seçebilirsin.',
        'You can choose how to approach your day.',
      ),
      LocalizedText(
        'Bu kart, gününü düşünmek için küçük bir başlangıç.',
        'This card is a small starting point for reflecting on your day.',
      ),
      LocalizedText(
        'Bugün hem hareket etmeye hem durmaya yer ayırabilirsin.',
        'You can make room for both action and pauses today.',
      ),
      LocalizedText(
        'Günün hikâyesini yaşadığın anlar oluşturur.',
        'The moments you live make up the story of your day.',
      ),
      LocalizedText(
        'Küçük bir deneme için kendine alan bırakabilirsin.',
        'You can leave yourself room for a small experiment.',
      ),
      LocalizedText(
        'Bugünkü temayı kendi gündelik hayatına uyarlayabilirsin.',
        'You can adapt this theme to your own everyday life.',
      ),
      LocalizedText(
        'Her günün aynı tempoda olması gerekmiyor.',
        'Every day does not need to have the same pace.',
      ),
    ],
    SkorBandi.yuksek: [
      LocalizedText(
        'Kartın yüksek puanını küçük bir oyun daveti sayabilirsin.',
        'You can treat the high card score as a small invitation to play.',
      ),
      LocalizedText(
        'Bugünkü kartın, merak ettiğin bir fikre eşlik edebilir.',
        'This card can accompany an idea you are curious about.',
      ),
      LocalizedText(
        'Bir fikre ayıracağın küçük zamanı kendin seçebilirsin.',
        'You can choose a little time to spend on an idea.',
      ),
      LocalizedText(
        'Bu kartın enerjisini kısa bir yaratıcı denemeye taşıyabilirsin.',
        'You can bring this card theme into a brief creative experiment.',
      ),
      LocalizedText(
        'Yüksek puan, gününü doldurman gerektiği anlamına gelmez.',
        'A high score does not mean you need to fill your day.',
      ),
      LocalizedText(
        'Bugün hoşuna giden bir ayrıntıyı görünür kılabilirsin.',
        'You can make a detail you enjoy visible today.',
      ),
      LocalizedText(
        'Bu kartı küçük bir merak daveti olarak düşünebilirsin.',
        'You can think of this card as a small invitation to curiosity.',
      ),
      LocalizedText(
        'Küçük bir adımı kutlamak için büyük sonuçlar gerekmiyor.',
        'You do not need big results to celebrate a small step.',
      ),
      LocalizedText(
        'Bugünün temasını kendine ait bir örnekle deneyebilirsin.',
        'You can try this theme with an example from your own life.',
      ),
    ],
    SkorBandi.cokYuksek: [
      LocalizedText(
        'Bu parlak kart, günlük oyunun renkli bir parçası.',
        'This bright card is a colorful part of the daily game.',
      ),
      LocalizedText(
        'Çok yüksek puan da gerçek hayatın sonucunu söylemez.',
        'Even a very high score does not tell you a real-life outcome.',
      ),
      LocalizedText(
        'Bu kartı küçük bir yaratıcılık molasıyla kutlayabilirsin.',
        'You can celebrate this card with a short creative break.',
      ),
      LocalizedText(
        'Bugünkü kartını sevdiğin bir ayrıntıyla eşleştirebilirsin.',
        'You can pair this card with a detail you enjoy.',
      ),
      LocalizedText(
        'Parlak bir kartın yanında sakin bir gün de mümkün.',
        'A quiet day can sit alongside a bright card.',
      ),
      LocalizedText(
        'Günün bu renkli temasına kendi anlamını katabilirsin.',
        'You can add your own meaning to this colorful theme.',
      ),
      LocalizedText(
        'Bu yüksek puan sana yeni bir zorunluluk yüklemez.',
        'This high score does not give you a new obligation.',
      ),
      LocalizedText(
        'Küçük bir denemeyi yalnızca merak ettiğin için yapabilirsin.',
        'You can try something small simply because you are curious.',
      ),
      LocalizedText(
        'Kartın parlaklığını bugün fark ettiğin bir anla hatırlayabilirsin.',
        'You can remember this bright card through a moment you notice today.',
      ),
    ],
  };
  static const List<LocalizedText> _closings = [
    LocalizedText(
      'Akşam günün sende bıraktığını kendi kelimelerinle işaretleyebilirsin.',
      'In the evening, you can note what the day left with you in your own words.',
    ),
    LocalizedText(
      'Bugünü nasıl yaşadığın, kartın yorumundan daha önemli.',
      'How you experience today matters more than the card commentary.',
    ),
    LocalizedText(
      'İstersen bu daveti kendi koşullarına göre değiştirebilirsin.',
      'You can adapt this invitation to your circumstances if you like.',
    ),
    LocalizedText(
      'Bir görevi atlamak da geçerli bir tercih.',
      'Skipping a task is a valid choice too.',
    ),
    LocalizedText(
      'Bu küçük ritüelde kendi deneyimine yer var.',
      'There is room for your own experience in this small ritual.',
    ),
    LocalizedText(
      'Günün sonunda tek bir kelime bile not olabilir.',
      'Even a single word can be a note at the end of the day.',
    ),
    LocalizedText(
      'Her ayrıntıyı anlamlandırmak zorunda değilsin.',
      'You do not have to find meaning in every detail.',
    ),
    LocalizedText(
      'Bugünkü denemenden kalan bir şeyi hatırlayabilirsin.',
      'You can remember one thing from what you tried today.',
    ),
    LocalizedText(
      'Kendi ölçünü ve sınırlarını yanında tutabilirsin.',
      'You can keep your own standards and boundaries with you.',
    ),
    LocalizedText(
      'Bazen yalnızca fark etmek yeterli olabilir.',
      'Sometimes simply noticing can be enough.',
    ),
    LocalizedText(
      'Bu kartı istediğin zaman yeniden okuyabilirsin.',
      'You can read this card again whenever you like.',
    ),
    LocalizedText(
      'Günün hikâyesinde son söz senin deneyiminde.',
      'Your experience has the final say in the story of your day.',
    ),
    LocalizedText(
      'Bir sonraki küçük adımın boyutunu sen seçebilirsin.',
      'You can choose the size of your next small step.',
    ),
    LocalizedText(
      'Bugünden tek bir anı kendine saklayabilirsin.',
      'You can keep one moment from today for yourself.',
    ),
  ];
}
