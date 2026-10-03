import 'legal_config.dart';

/// Yasal belgenin tek bölümü.
class YasalBolum {
  /// [baslik] ve [metin] ile bölüm oluşturur.
  const YasalBolum({required this.baslik, required this.metin});

  /// Bölüm başlığı.
  final String baslik;

  /// Bölüm metni (paragraflar boş satırla ayrılır).
  final String metin;
}

/// Uygulama içi uyarı, gizlilik politikası ve kullanım koşulları.
///
/// Metinler web sitesindeki sürümlerle birebir aynı tutulmalıdır; web
/// için HTML karşılıkları geliştiriciye ayrıca teslim edilmiştir.
/// Bu metinler bir hukuk danışmanı tarafından gözden geçirilmelidir.
abstract final class YasalMetinler {
  /// Uyarı ekranındaki onay sonrası devam butonu.
  static const String devam = 'Devam';

  /// Onboarding başındaki uyarının başlığı.
  static const String uyariBaslik = 'Başlamadan önce';

  /// Onboarding uyarısının maddeleri.
  static const List<String> uyariMaddeleri = <String>[
    'Kader bir eğlence ve kendini keşfetme uygulamasıdır. Yorumlar '
        'numeroloji ve astroloji geleneğinden esinlenen hesaplarla '
        've önceden yazılmış metinlerle üretilir; bilimsel bir öngörü '
        'değildir ve geleceği bildiği iddiasında bulunmaz.',
    'Sağlık, para, hukuk, eğitim ya da ilişkilerinle ilgili önemli '
        'kararlarını yalnızca bu yorumlara dayanarak verme. Böyle '
        'konularda bir uzmana danış.',
    'Adın, doğum tarihin ve verdiğin cevaplar yalnızca bu cihazda '
        'saklanır; Kader bunları bir sunucuya göndermez.',
    'Uygulama ücretsiz sürümde reklam gösterir. Reklam ortağımız Google '
        'AdMob, reklam kimliğin gibi bazı cihaz verilerini işleyebilir; '
        'bölgene göre senden ayrıca izin istenir.',
    'Premium abonelik Google Play üzerinden satın alınır, iptal edilene '
        'kadar otomatik yenilenir ve Google Play ayarlarından her an '
        'iptal edilebilir.',
  ];

  /// Kabul kutusunun metni.
  static const String uyariKabul =
      'Okudum; Kullanım Koşulları\'nı ve Gizlilik Politikası\'nı kabul '
      'ediyorum. 13 yaşından büyüğüm.';

  /// Uygulama içinde her yerde kullanılabilecek tek satırlık not.
  static const String kisaNot =
      'Kader eğlence amaçlıdır; yorumlar bilimsel öngörü değildir.';

  /// Gizlilik Politikası.
  static const List<YasalBolum> gizlilikPolitikasi = <YasalBolum>[
    YasalBolum(
      baslik: 'Kapsam',
      metin: 'Bu Gizlilik Politikası, ${LegalConfig.gelistiriciAdi} '
          '("biz") tarafından geliştirilen Kader mobil uygulamasının '
          '("Uygulama") hangi kişisel verileri nasıl işlediğini açıklar. '
          '6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) ve '
          'uygulanabildiği ölçüde Avrupa Birliği Genel Veri Koruma Tüzüğü '
          '(GDPR) kapsamında hazırlanmıştır. Son güncelleme: '
          '${LegalConfig.sonGuncelleme}.',
    ),
    YasalBolum(
      baslik: 'Cihazında saklanan veriler',
      metin: 'Uygulamayı kullanabilmen için girdiğin adın, isteğe bağlı '
          'tam adın, doğum tarihin, tanışma sorularına verdiğin cevaplar '
          '(enerji tarzı, karar tarzı, ilişki durumu, günlük uğraş), '
          'günlük skor kayıtların, yorumlara verdiğin geri bildirimler ve '
          'uyum ekranına eklediğin kişilerin ad ve doğum tarihleri '
          'YALNIZCA cihazındaki yerel veritabanında saklanır. Bu veriler '
          'bize veya herhangi bir sunucuya gönderilmez; yorumlar tamamen '
          'cihazında hesaplanır.\n\n'
          'Uyum ekranına başka bir kişinin bilgilerini eklerken o kişinin '
          'bundan haberdar olmasına ve izin vermesine dikkat etmelisin.',
    ),
    YasalBolum(
      baslik: 'Reklamlar (Google AdMob)',
      metin: 'Ücretsiz sürümde Google LLC tarafından sağlanan AdMob '
          'reklam hizmeti kullanılır. AdMob; reklam göstermek, sıklığını '
          'sınırlamak, kötüye kullanımı önlemek ve reklam performansını '
          'ölçmek için cihazının reklam kimliği, IP adresi, cihaz ve '
          'uygulama bilgileri ile reklam etkileşimleri gibi verileri '
          'işleyebilir. Avrupa Ekonomik Alanı, Birleşik Krallık ve '
          'İsviçre gibi bölgelerde, kişiselleştirilmiş reklamlar için '
          'Google\'ın rıza formu aracılığıyla izin istenir ve bu tercihini '
          'Ayarlar > Reklam gizlilik tercihleri bölümünden değiştirebilirsin. '
          'Cihaz ayarlarından reklam kimliğini sıfırlayabilir veya '
          'kişiselleştirilmiş reklamları kapatabilirsin. Google\'ın veri '
          'işleme uygulamaları için: policies.google.com/technologies/partner-sites',
    ),
    YasalBolum(
      baslik: 'Satın alımlar (Google Play Faturalandırma)',
      metin: 'Premium abonelik ödemeleri Google Play tarafından işlenir. '
          'Ödeme bilgilerin bize iletilmez. Aboneliğinin aktif olup '
          'olmadığını doğrulamak için Google Play\'in cihazına sağladığı '
          'satın alma kaydı kullanılır.',
    ),
    YasalBolum(
      baslik: 'Bildirimler',
      metin: 'Sabah ve akşam hatırlatmaları cihazında yerel olarak '
          'planlanır; bir sunucu üzerinden gönderilmez. Bildirim iznini '
          'cihaz ayarlarından her an kapatabilirsin.',
    ),
    YasalBolum(
      baslik: 'İşleme amaçları ve hukuki sebepler',
      metin: 'Cihazdaki veriler, sözleşmenin ifası kapsamında sana '
          'kişisel yorum sunmak için işlenir. Reklam verileri, bölgene '
          'göre açık rızana veya meşru menfaate dayanarak Google tarafından '
          'işlenir. Satın alma kayıtları sözleşmenin ifası için kullanılır.',
    ),
    YasalBolum(
      baslik: 'Saklama süresi ve silme',
      metin: 'Cihazındaki veriler, sen silene kadar saklanır. Ayarlar > '
          'Verilerimi sil seçeneği tüm yerel verileri kalıcı olarak siler; '
          'uygulamayı kaldırmak da aynı sonucu doğurur. Google\'ın işlediği '
          'reklam verileri Google\'ın saklama politikalarına tabidir.',
    ),
    YasalBolum(
      baslik: 'Çocukların gizliliği',
      metin: 'Kader 13 yaşın altındaki çocuklara yönelik değildir ve '
          'bilerek 13 yaşından küçüklerden veri toplamaz.',
    ),
    YasalBolum(
      baslik: 'Hakların',
      metin: 'KVKK\'nın 11. maddesi ve GDPR kapsamında verilerinin '
          'işlenip işlenmediğini öğrenme, düzeltilmesini veya silinmesini '
          'isteme, işlemeye itiraz etme ve rızanı geri alma haklarına '
          'sahipsin. Verilerin yalnızca cihazında tutulduğundan bu hakların '
          'çoğunu doğrudan uygulama içinden kullanabilirsin. Diğer talepler '
          'için ${LegalConfig.destekEposta} adresine yazabilirsin.',
    ),
    YasalBolum(
      baslik: 'Değişiklikler ve iletişim',
      metin: 'Bu politika güncellenebilir; önemli değişikliklerde uygulama '
          'içinde bilgilendirilirsin. Güncel sürüm: '
          '${LegalConfig.gizlilikUrl}\n\n'
          'Veri sorumlusu: ${LegalConfig.gelistiriciAdi}\n'
          'İletişim: ${LegalConfig.destekEposta}',
    ),
  ];

  /// Kullanım Koşulları.
  static const List<YasalBolum> kullanimKosullari = <YasalBolum>[
    YasalBolum(
      baslik: 'Kabul',
      metin: 'Kader\'i kullanarak bu Kullanım Koşulları\'nı kabul etmiş '
          'olursun. Kabul etmiyorsan uygulamayı kullanmamalısın. Son '
          'güncelleme: ${LegalConfig.sonGuncelleme}.',
    ),
    YasalBolum(
      baslik: 'Hizmetin niteliği: yalnızca eğlence',
      metin: 'Kader\'deki skorlar, yorumlar, uyum sonuçları, şanslı saat, '
          'renk ve sayılar; numeroloji ve astroloji geleneklerinden '
          'esinlenen, deterministik bir algoritma ve önceden yazılmış '
          'metinlerle üretilen EĞLENCE içerikleridir. Bilimsel bir '
          'dayanakları yoktur; geleceği öngörmez, kişilik tespiti yapmaz.',
    ),
    YasalBolum(
      baslik: 'Tavsiye değildir',
      metin: 'Uygulamadaki hiçbir içerik tıbbi, psikolojik, finansal, '
          'yatırım, hukuki veya profesyonel tavsiye değildir. Bu alanlardaki '
          'kararlarını Kader\'e dayanarak verme; gerektiğinde yetkili bir '
          'uzmana başvur. İçeriklere dayanarak alınan kararlardan doğan '
          'sonuçlardan ${LegalConfig.gelistiriciAdi} sorumlu tutulamaz.',
    ),
    YasalBolum(
      baslik: 'Premium abonelik',
      metin: 'Premium, Google Play üzerinden aylık veya yıllık abonelik '
          'olarak sunulur. Fiyat ve varsa ücretsiz deneme süresi satın alma '
          'ekranında gösterilir. Abonelik, dönem bitmeden en az 24 saat önce '
          'iptal edilmezse aynı süre ve fiyatla otomatik olarak yenilenir. '
          'Aboneliğini Google Play Store > Profil > Ödemeler ve abonelikler > '
          'Abonelikler yolundan yönetebilir veya iptal edebilirsin; iptal, '
          'mevcut dönemin sonunda geçerli olur. Ücretsiz deneme sona '
          'ermeden iptal edilmezse ücretli döneme geçilir. İadeler Google '
          'Play\'in iade politikalarına tabidir.',
    ),
    YasalBolum(
      baslik: 'Reklamlar',
      metin: 'Ücretsiz sürüm üçüncü taraf reklamları içerir. İsteğe bağlı '
          'ödüllü reklamları izleyerek bazı içerikleri o gün için '
          'açabilirsin; ödül, reklamın sonuna kadar izlenmesine bağlıdır ve '
          'reklam bulunamadığında verilemeyebilir.',
    ),
    YasalBolum(
      baslik: 'Kullanıcı sorumlulukları',
      metin: 'Uygulamaya başka kişilere ait bilgi eklerken onların '
          'haklarına saygı göstermeli, uygulamayı hukuka aykırı amaçlarla '
          'kullanmamalısın. Uygulamanın kaynak kodunu kopyalamak, tersine '
          'mühendislik yapmak veya içerikleri izinsiz çoğaltmak yasaktır.',
    ),
    YasalBolum(
      baslik: 'Fikri mülkiyet',
      metin: 'Uygulamadaki metinler, görseller ve yazılım '
          '${LegalConfig.gelistiriciAdi}\'na aittir veya lisanslıdır. '
          'Paylaşım kartlarını kişisel sosyal medya paylaşımlarında '
          'kullanabilirsin.',
    ),
    YasalBolum(
      baslik: 'Sorumluluğun sınırlandırılması',
      metin: 'Uygulama "olduğu gibi" sunulur. Kesintisiz veya hatasız '
          'çalışacağı taahhüt edilmez. Yürürlükteki mevzuatın izin verdiği '
          'ölçüde, uygulamanın kullanımından doğan dolaylı zararlardan '
          'sorumluluk kabul edilmez. Tüketici mevzuatından doğan '
          'hakların saklıdır.',
    ),
    YasalBolum(
      baslik: 'Değişiklikler, uygulanacak hukuk ve iletişim',
      metin: 'Koşullar güncellenebilir; önemli değişikliklerde uygulama '
          'içinde yeniden onayın istenir. Bu koşullara Türkiye Cumhuriyeti '
          'hukuku uygulanır. Güncel sürüm: ${LegalConfig.kosullarUrl}\n\n'
          'İletişim: ${LegalConfig.destekEposta}',
    ),
  ];
}
