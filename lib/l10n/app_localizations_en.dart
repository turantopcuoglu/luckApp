// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sekmeBugun => 'Today';

  @override
  String get sekmeProfil => 'Profile';

  @override
  String get sekmeUyum => 'Match';

  @override
  String get sekmeKesfet => 'Explore';

  @override
  String get sekmeAyarlar => 'Settings';

  @override
  String get ayarlarBaslik => 'Settings';

  @override
  String get ayarlarProfil => 'Profile';

  @override
  String get ayarlarAd => 'Your name';

  @override
  String get ayarlarDogumTarihi => 'Your birth date';

  @override
  String get ayarlarSabitAlanNotu =>
      'Your daily score is calculated from these two details, so they can\'t be changed. If you entered them wrong, you can delete your data and start over.';

  @override
  String get ayarlarTamAd => 'Your full name at birth';

  @override
  String get ayarlarTamAdYok => 'Not added — add it for your name numbers';

  @override
  String get ayarlarPremium => 'Premium';

  @override
  String get ayarlarPremiumAktif => 'Premium is active';

  @override
  String get ayarlarPremiumDegil => 'Free version';

  @override
  String get ayarlarPremiumaGec => 'Go Premium';

  @override
  String get ayarlarAboneligiYonet => 'Manage your subscription';

  @override
  String get ayarlarGeriYukle => 'Restore purchases';

  @override
  String get ayarlarBildirimler => 'Notifications';

  @override
  String get ayarlarBildirimSaatleri => 'Morning 08:30 · Evening 21:00';

  @override
  String get ayarlarBildirimAciklama =>
      'To turn notifications off, go to Settings > Apps > Solenia > Notifications on your phone.';

  @override
  String get ayarlarBildirimleriTazele => 'Set up notifications again';

  @override
  String get ayarlarBildirimlerKuruldu =>
      'Notifications have been set up again.';

  @override
  String get ayarlarDil => 'Language';

  @override
  String get ayarlarDilCihaz => 'Device language';

  @override
  String get ayarlarGizlilikYasal => 'Privacy and legal';

  @override
  String get ayarlarReklamGizlilik => 'Ad privacy preferences';

  @override
  String get ayarlarUyari => 'Notice: for entertainment only';

  @override
  String get ayarlarLisanslar => 'Licenses';

  @override
  String get ayarlarVerileriSil => 'Delete my data';

  @override
  String get ayarlarVerileriSilAciklama =>
      'Your profile, daily records, feedback and the people you added will be permanently deleted from this device. Your Premium subscription continues on Google Play; use Google Play to cancel it.';

  @override
  String get ayarlarSilOnayBaslik => 'Delete all data?';

  @override
  String get ayarlarSil => 'Delete permanently';

  @override
  String get ayarlarVazgec => 'Cancel';

  @override
  String get ayarlarTamam => 'OK';

  @override
  String get ayarlarGelistirici => 'Developer (debug only)';

  @override
  String get ayarlarPremiumSimulasyonu => 'Premium simulation';

  @override
  String get ayarlarRizaSifirla => 'Reset ad consent';

  @override
  String get ayarlarRizaSifirlandi =>
      'Consent reset; the form will appear again after you restart the app.';

  @override
  String ayarlarSurum(String surum) {
    return 'Solenia $surum';
  }

  @override
  String get onboardingUygulamaAdi => 'Solenia';

  @override
  String get onboardingSlogan => 'Your luck is rewritten every morning.';

  @override
  String get onboardingKarsilamaAciklama =>
      'A reading written just for you every day, from the numbers in your birth date and name.';

  @override
  String get onboardingBasla => 'Get started';

  @override
  String get onboardingTamAdEtiketi => 'Your full name at birth';

  @override
  String get onboardingTamAdIpucu => 'First Middle Last';

  @override
  String get onboardingTamAdAciklama =>
      'Your name, soul and personality numbers are calculated from your full name as registered at birth. We will call you by your first name.';

  @override
  String get onboardingDogumTarihiEtiketi => 'Your birth date';

  @override
  String get onboardingDogumTarihiAciklama =>
      'Your life path number and zodiac sign come from this date, so please enter it correctly.';

  @override
  String get onboardingDogumSaatiYeriEtiketi =>
      'Your birth time and place (if you know them)';

  @override
  String get onboardingDogumSaatiYeriAciklama =>
      'Your Moon and rising signs are calculated from these. If you do not know the time, leave it empty; you can add it later from your profile.';

  @override
  String get onboardingKaderimiHesapla => 'Read my stars';

  @override
  String get onboardingIsimBosUyarisi => 'Enter your name to continue.';

  @override
  String get onboardingRituelNotu => 'A daily ritual of inspiration.';

  @override
  String get onboardingKartHazirlaniyor => 'Preparing your card';

  @override
  String get onboardingHazirlikProfil => 'Profile ready';

  @override
  String get onboardingHazirlikKart => 'Preparing your daily card';

  @override
  String get onboardingHazirlikSon => 'Final touches';

  @override
  String get onboardingKendineAlanAc => 'Make a little space for yourself.';

  @override
  String get onboardingKartinHazir => 'Your card is ready';

  @override
  String get onboardingKartinHazirAlt =>
      'Choose one small step for yourself today.';

  @override
  String get onboardingHazirlikTamamlandi => 'All set';

  @override
  String get onboardingKartimaGec => 'Go to my card';

  @override
  String get yasalUyariBaslik => 'Before you begin';

  @override
  String get yasalDevam => 'Continue';

  @override
  String get yasalGizlilikPolitikasi => 'Privacy Policy';

  @override
  String get yasalKullanimKosullari => 'Terms of Use';

  @override
  String get tarihDeseni => 'EEEE, MMMM d, y';

  @override
  String get kisaTarihDeseni => 'MMMM d, y';

  @override
  String get gunlukGenelSkor => 'OVERALL SCORE';

  @override
  String get gunlukYukleniyor => 'Reading your sky...';

  @override
  String get gunlukKartHazir => 'Today\'s card is ready';

  @override
  String get gunlukKendineBirDakika => 'Take a minute for yourself.';

  @override
  String get gunlukKartimiAc => 'Open my card';

  @override
  String get gunlukSansPuani => 'Today\'s luck score';

  @override
  String gunlukPuanPaydasi(int maks) {
    return '/ $maks';
  }

  @override
  String gunlukPuanSemantik(int skor, int maks) {
    return 'Today\'s luck score: $skor / $maks';
  }

  @override
  String get gunlukHata => 'Something went wrong. Try restarting the app.';

  @override
  String gunlukSelamlama(String isim) {
    return 'Hello, $isim';
  }

  @override
  String get gunlukSansRengi => 'Your lucky color';

  @override
  String get gunlukSansliSayi => 'Your lucky number';

  @override
  String get gunlukTavsiye => 'Today\'s advice';

  @override
  String get gunlukSeniAnlattiMi => 'Did this reading describe you?';

  @override
  String get gunlukEvet => 'Yes';

  @override
  String get gunlukHayir => 'No';

  @override
  String get gunlukAnlattiTesekkur =>
      'Great! We\'ve noted that you like readings like this ✨';

  @override
  String get gunlukAnlatmadiTesekkur =>
      'Thanks. We won\'t show you this reading again in the coming days.';

  @override
  String get gunlukNedenBugun => 'Why today?';

  @override
  String get gunlukNedenNotu => 'Today\'s reading grows out of these signs.';

  @override
  String get gunlukAksamBaslik => 'How was your day?';

  @override
  String get gunlukAksamAciklama =>
      'Were you really lucky today? Your answer helps Solenia keep track of how accurate it is for you.';

  @override
  String get gunlukAksamButon => 'Answer';

  @override
  String get gunlukAlanlarBaslik => 'Today\'s areas';

  @override
  String get gunlukAlanlarAlt => 'Tap an area to see the details.';

  @override
  String get gunlukGununYildizi => 'Today\'s star';

  @override
  String get gunlukKilidiAc => 'Unlock';

  @override
  String gunlukKilitliPuanSemantik(String kategori) {
    return '$kategori score locked';
  }

  @override
  String get gunlukBolumEnerji => 'Today\'s energy';

  @override
  String gunlukBolumParlayan(String kategori) {
    return 'Spotlight · $kategori';
  }

  @override
  String gunlukBolumDikkat(String kategori) {
    return 'Watch out · $kategori';
  }

  @override
  String gunlukDevaminiOku(String kategori) {
    return 'Your full $kategori reading';
  }

  @override
  String get kategoriSansliSaat => 'Your lucky hours';

  @override
  String get kategoriYap => 'Do';

  @override
  String get kategoriYapma => 'Don\'t';

  @override
  String kategoriKilitAciklamasi(String kategori) {
    return 'Today\'s $kategori score, your personal reading and your lucky hours are open to Premium members. You can also unlock them for today only by watching a short ad.';
  }

  @override
  String kategoriKilitOnizleme(String kategori) {
    return 'What\'s waiting for you in $kategori today:';
  }

  @override
  String get kategoriKilitEnYuksek =>
      'Your highest score today is in this area.';

  @override
  String get kategoriKilitIcerik =>
      'Your score · Personal reading · Do / Don\'t · Lucky hours';

  @override
  String get geriBildirimAksamSorusu => 'Were you really lucky today?';

  @override
  String get geriBildirimBaslik => 'How was your day?';

  @override
  String get geriBildirimEmojiBaslik => 'Leave an emoji if you like';

  @override
  String get geriBildirimKaydet => 'Save';

  @override
  String get geriBildirimTesekkur => 'Saved, see you tomorrow ✨';

  @override
  String get geriBildirimIzinReddi =>
      'No problem! You can turn on notifications later in your phone\'s settings.';

  @override
  String get bildirimKanalAd => 'Daily reminders';

  @override
  String get bildirimKanalAciklama =>
      'Morning reading-ready and evening feedback reminders';

  @override
  String get bildirimSabah1 => 'Today\'s sky is ready ✨';

  @override
  String get bildirimSabah2 => 'The stars lined up for you, come and see 🌟';

  @override
  String get bildirimSabah3 =>
      'A new day, a new chance. Your score is waiting 🍀';

  @override
  String get bildirimSabah4 => 'Today\'s card is waiting to be opened 🎴';

  @override
  String get bildirimSabah5 =>
      'Are you lucky today? There\'s only one way to find out 👀';

  @override
  String get bildirimSabah6 =>
      'Don\'t head out without a look: your sky is ready ☕';

  @override
  String get bildirimSabah7 =>
      'What is the universe whispering today? Tap your card 🔮';

  @override
  String get bildirimSabah8 => 'Your score is ready. Dare to look? 😏';

  @override
  String get bildirimSabah9 =>
      'The moon phase did its part, now it\'s your turn 🌙';

  @override
  String get bildirimSabah10 =>
      'Today\'s energy has been measured. The result is inside ⚡';

  @override
  String get bildirimSabah11 =>
      'Your stars are at the door. Open it to find out 🚪';

  @override
  String get bildirimSabah12 =>
      'The luck fairies finished their shift, the report is ready 🧚';

  @override
  String get paylasimPaylas => 'Share';

  @override
  String get paylasimMarka => 'Solenia ✨';

  @override
  String get paylasimGenelSkor => 'TODAY\'S LUCK SCORE';

  @override
  String get paylasimMetni => 'My stars today ✨';

  @override
  String get paylasimAracDavet => 'Calculate yours: the Solenia app';

  @override
  String get paylasimKartiniPaylas => 'Share your card';

  @override
  String get paylasimSkoruGizle => 'Hide score';

  @override
  String get paylasimMenusunuAcar => 'Opens the share menu';

  @override
  String paylasimTemaSecimi(String tema) {
    return '$tema theme';
  }

  @override
  String get paylasimTemaGece => 'Night';

  @override
  String get paylasimTemaIsik => 'Light';

  @override
  String get paylasimTemaMor => 'Purple';

  @override
  String get profilBaslik => 'Your Sky Profile';

  @override
  String get profilAciklama =>
      'The numbers that come from your birth date and name; they don\'t change over time. Tap any number to read its meaning.';

  @override
  String get profilYasamYolu => 'Life Path';

  @override
  String get profilIsimSayisi => 'Name';

  @override
  String get profilRuhSayisi => 'Soul';

  @override
  String get profilKisilikSayisi => 'Personality';

  @override
  String get profilTamAdEkle => 'Add your full name';

  @override
  String get profilTamAdEksikBaslik => 'Your name numbers are missing';

  @override
  String get profilTamAdEksikAciklama =>
      'Your name, soul and personality numbers come from your full name at birth. Add it and two new sections open in your profile.';

  @override
  String get profilUstaSayi => 'Master number';

  @override
  String get profilKilidiAc => 'Unlock';

  @override
  String get profilKilitAciklamasi =>
      'Your full profile — your shadow side, love and work life, life lesson, inner voice and this year\'s theme — is open to Premium members. You can also unlock it for today by watching a short ad.';

  @override
  String get profilSinirGunu => 'Cusp';

  @override
  String get profilRaporGirisBaslik => 'Your Numerology Report';

  @override
  String get profilRaporGirisAciklama =>
      'The four periods of your life, your karmic numbers and the hidden meanings of your name.';

  @override
  String get profilRaporBaslik => 'Your Numerology Report';

  @override
  String get profilRaporAciklama =>
      'Themes about the long periods of your life, calculated from your birth date and full name. This report is a map of tendencies; it doesn\'t describe events but what each period is trying to teach you.';

  @override
  String get profilZamanCizelgesiBaslik => 'The four periods of your life';

  @override
  String get profilSuAn => 'Now';

  @override
  String profilZirve(int zirve) {
    return 'Pinnacle $zirve';
  }

  @override
  String get profilBuyukUcluBaslik => 'Your Big Three';

  @override
  String get profilBuyukUcluAciklama =>
      'Your Sun sign describes who you are, your Moon sign how you feel, and your Rising how the world sees you.';

  @override
  String get profilGunes => 'Sun';

  @override
  String get profilAy => 'Moon';

  @override
  String get profilYukselen => 'Rising';

  @override
  String get profilYukseleniniOgren => 'Find your Rising';

  @override
  String get profilHaritaniOku => 'Read your chart';

  @override
  String profilGunesBasligi(String burc) {
    return 'Your Sun sign · $burc';
  }

  @override
  String get profilHaritaKilitAciklamasi =>
      'Your Rising reading is open to Premium members. You can also unlock it for today by watching a short ad.';

  @override
  String get profilDogumBilgisiBaslik => 'Your birth time and place';

  @override
  String get profilDogumBilgisiAciklama =>
      'Your Rising sign depends on your birth time and where you were born. Enter the time on your birth record or the one your family remembers; even a few minutes can change your Rising.';

  @override
  String get profilDogumSaati => 'Birth time';

  @override
  String get profilSaatBilinmiyor => 'I don\'t know';

  @override
  String get profilSaatSec => 'Choose time';

  @override
  String get profilDogumIli => 'Province of birth';

  @override
  String get profilDogumIliIpucu => 'Type a province (e.g. İzmir)';

  @override
  String get profilDogumUlkesi => 'Country of birth';

  @override
  String get profilDogumUlkesiIpucu => 'Type a country';

  @override
  String get profilDogumSehri => 'City of birth';

  @override
  String get profilDogumSehriIpucu => 'Type a city (e.g. Berlin)';

  @override
  String get profilEnYakinSehir =>
      'If your town isn\'t listed, choose the nearest city.';

  @override
  String get profilSehirListesiYok =>
      'The city list couldn\'t be opened. Restart the app and try again.';

  @override
  String get profilKaydet => 'Save';

  @override
  String profilYilRaporuKartBaslik(int yil) {
    return 'Your $yil Personal Year Report';
  }

  @override
  String profilYilRaporuKartAciklama(int yil, String yilLakabi) {
    return '$yil is your $yilLakabi. The year\'s opportunities, your flow months and your month-by-month guide are ready.';
  }

  @override
  String profilYilRaporuBaslik(int yil) {
    return 'Your $yil Report';
  }

  @override
  String get profilKisiselYilEtiketi => 'Your personal year';

  @override
  String profilAyAyBaslik(int yil) {
    return '$yil month by month';
  }

  @override
  String get profilAkisCipi => 'In flow';

  @override
  String get profilZorluCipi => 'Challenging';

  @override
  String get profilRaporTamAdEksikBaslik => 'Your report is incomplete';

  @override
  String get profilRaporTamAdEksikAciklama =>
      'Your karmic lessons, hidden passion, maturity number and the letters of your name come from your full name at birth. Add it and five new sections open in your report.';

  @override
  String get tamAdBaslik => 'Your full name at birth';

  @override
  String get tamAdAciklama =>
      'Write it as on your birth record, including middle names (e.g. Ayşe Nur Yılmaz). Don\'t use short forms or nicknames; your name numbers are calculated from this name. Your daily score won\'t change.';

  @override
  String get tamAdIpucu => 'First Middle Last';

  @override
  String get tamAdKaydet => 'Save';

  @override
  String get tamAdKaldir => 'Remove';

  @override
  String get tamAdVazgec => 'Cancel';

  @override
  String get premiumBaslik => 'Solenia Premium';

  @override
  String get premiumAltBaslik =>
      'See your whole sky: every day, every category, ad-free.';

  @override
  String get premiumOzellik1 => 'Love and Money categories open every day';

  @override
  String get premiumOzellik2 =>
      'Full Sky Profile: your shadow side, love, work, life lesson, inner voice';

  @override
  String get premiumOzellik3 =>
      'Personal year reading and the theme of your year';

  @override
  String get premiumOzellik4 =>
      'Your full Numerology Report: the four periods of your life and your karmic numbers';

  @override
  String get premiumOzellik5 =>
      'A Personal Year Report every year: your month-by-month guide';

  @override
  String get premiumOzellik6 => 'Unlimited compatibility checks';

  @override
  String get premiumOzellik7 => 'Ad-free experience';

  @override
  String get premiumYillik => 'Yearly';

  @override
  String get premiumAylik => 'Monthly';

  @override
  String get premiumEnAvantajli => 'Best value';

  @override
  String premiumAyliginaDusen(String fiyat) {
    return 'about $fiyat per month';
  }

  @override
  String premiumDeneme(int gun) {
    return 'Try free for $gun days';
  }

  @override
  String get premiumDonemYil => '/ year';

  @override
  String get premiumDonemAy => '/ month';

  @override
  String get premiumAbonelikBaslat => 'Start subscription';

  @override
  String get premiumDenemeBaslat => 'Start free trial';

  @override
  String get premiumGeriYukle => 'Restore purchases';

  @override
  String get premiumYukleniyor => 'Loading subscription options…';

  @override
  String get premiumPlanYok =>
      'Subscription options can\'t be shown right now. Make sure the app was installed from Google Play and you\'re connected to the internet.';

  @override
  String get premiumTekrarDene => 'Try again';

  @override
  String get premiumYenilemeBilgisi =>
      'The subscription renews automatically for the same period and price unless it\'s cancelled at least 24 hours before the period ends. If the free trial isn\'t cancelled before it ends, the paid period begins. You can cancel any time in Google Play > Payments & subscriptions.';

  @override
  String get premiumPuanNotu => 'Premium doesn\'t change your luck score.';

  @override
  String get premiumZatenPremium => 'Your Premium membership is active ✨';

  @override
  String get premiumBasarili => 'Premium is unlocked. Enjoy ✨';

  @override
  String get premiumKilitBaslik => 'This content is Premium';

  @override
  String get premiumPremiumaGec => 'Go Premium';

  @override
  String get premiumReklamlaAc => 'Watch an ad to unlock for today';

  @override
  String get premiumReklamYok =>
      'No ad is available right now. You can try again in a little while.';

  @override
  String get premiumOdulYok =>
      'The ad wasn\'t completed, so the content couldn\'t be unlocked.';

  @override
  String get premiumAcildi => 'Unlocked for today ✨';

  @override
  String get premiumKisiSiniri =>
      'In the free version you can check compatibility with one person. Go Premium for unlimited people.';

  @override
  String get premiumRaporKilitBaslik => 'Unlock your full report';

  @override
  String get premiumRaporKilitAciklama =>
      'This period\'s lesson, your next period, your karmic debts, the numbers missing from your name, your hidden passion, your maturity number and the letters of your name — your full report unlocks permanently with a one-time payment.';

  @override
  String premiumRaporuSatinAl(String fiyat) {
    return 'Unlock report · $fiyat';
  }

  @override
  String get premiumRaporFiyatYukleniyor => 'Loading price…';

  @override
  String get premiumRaporPremiumSecenegi => 'Go Premium — report included';

  @override
  String get premiumRaporOdemeBilgisi =>
      'This is a one-time payment, not a subscription. The report stays unlocked on this Google account; if you change devices, use \"Restore purchases\" to unlock it again.';

  @override
  String premiumYilRaporuKilitBaslik(int yil) {
    return 'Unlock your full $yil report';
  }

  @override
  String get premiumYilRaporuKilitAciklama =>
      'The year\'s opportunities and pitfalls, your love, work and money guide, the months when you\'ll be in flow and those that may challenge you, a month-by-month reading and the question of the year — unlocked permanently with a one-time payment.';

  @override
  String get premiumYilRaporuPremiumSecenegi =>
      'Go Premium — every year\'s report included';

  @override
  String get premiumRaporAcildi => 'Your report is unlocked ✨';

  @override
  String get premiumYonetimBilgisi =>
      'You can manage or cancel your subscription in the Google Play Store app under Profile > Payments & subscriptions > Subscriptions.';

  @override
  String get premiumHataPlanlar =>
      'Subscription options couldn\'t be loaded right now. Check your internet connection and try again.';

  @override
  String get premiumHataSatinAlmaBaslamadi =>
      'The purchase couldn\'t be started. Make sure you\'re signed in to Google Play and try again.';

  @override
  String get premiumHataSatinAlma =>
      'The purchase couldn\'t be completed. If you weren\'t charged, you can try again.';

  @override
  String get premiumHataOdemeBekleniyor =>
      'Your payment is awaiting approval. Premium will unlock automatically once it\'s approved.';

  @override
  String get premiumHataRaporUrunuYok =>
      'The report can\'t be purchased right now. Make sure the app was installed from Google Play and you\'re connected to the internet.';

  @override
  String get premiumHataGeriYukleme =>
      'Purchases couldn\'t be restored. Make sure you\'re signed in with the same Google account.';

  @override
  String get araclarBaslik => 'Discover';

  @override
  String get araclarAciklama =>
      'Names and numbers have their own numbers too. Calculate a name you\'re curious about, your phone number, or the names you\'re considering for your baby.';

  @override
  String get araclarIsimBaslik => 'Name Analysis';

  @override
  String get araclarIsimAciklama =>
      'The name, soul and personality numbers of any name.';

  @override
  String get araclarNumaraBaslik => 'Number Analysis';

  @override
  String get araclarNumaraAciklama =>
      'The number and energy of your phone, license plate or house number.';

  @override
  String get araclarBebekBaslik => 'Baby Name';

  @override
  String get araclarBebekAciklama =>
      'How well your candidate names match your family numerologically.';

  @override
  String get araclarHesapla => 'Calculate';

  @override
  String get araclarPaylas => 'Share';

  @override
  String get araclarGecersiz => 'There are no letters or digits to calculate.';

  @override
  String get araclarIsimKartEtiketi => 'NAME ANALYSIS';

  @override
  String get araclarNumaraKartEtiketi => 'NUMBER ANALYSIS';

  @override
  String get araclarBebekKartEtiketi => 'BABY NAME';

  @override
  String get araclarIsimSayisiEtiketi => 'Name number';

  @override
  String get araclarAdEtiketi => 'Full name';

  @override
  String get araclarAdIpucu => 'e.g. Emma Wilson';

  @override
  String get araclarNumaraEtiketi => 'Number';

  @override
  String get araclarTurTelefon => 'Phone';

  @override
  String get araclarTurTelefonIpucu => 'e.g. 555 123 4567';

  @override
  String get araclarTurPlaka => 'Plate';

  @override
  String get araclarTurPlakaIpucu => 'e.g. ABC 1234';

  @override
  String get araclarTurEv => 'House';

  @override
  String get araclarTurEvIpucu => 'e.g. Apt 7 or 12/4';

  @override
  String araclarHesapSatiri(String zincir) {
    return 'Total $zincir';
  }

  @override
  String get araclarAdaylarEtiketi => 'Candidate names';

  @override
  String get araclarAdaylarIpucu =>
      'Write one full name per line.\ne.g. Emma Wilson\nNoah Wilson';

  @override
  String get araclarEbeveynBaslik => 'Who should we compare with?';

  @override
  String get araclarEbeveynAciklama =>
      'People you added in the Compatibility tab appear here too.';

  @override
  String araclarBen(String isim) {
    return 'Me ($isim)';
  }

  @override
  String get araclarKisiSec => 'Choose at least one person.';

  @override
  String araclarPuan(int puan) {
    return 'Match $puan/100';
  }

  @override
  String get araclarSiralamaBaslik => 'Candidate ranking';

  @override
  String get araclarSiralamaKilitli =>
      'The ranking of all candidates by match score is open to Premium members.';

  @override
  String araclarSiraSatiri(int sira, String ad, int puan) {
    return '$sira. $ad · $puan';
  }

  @override
  String get uyumBaslik => 'Compatibility';

  @override
  String get uyumAciklama =>
      'See how your numbers and signs match with your partner, a crush, a friend or a family member.';

  @override
  String get uyumBosDurum =>
      'You haven\'t added anyone yet. Add your first person to discover how well you match.';

  @override
  String get uyumKisiEkle => 'Add person';

  @override
  String get uyumFormBaslik => 'New person';

  @override
  String get uyumAdEtiketi => 'Full name';

  @override
  String get uyumAdIpucu => 'First Last (with middle name, if any)';

  @override
  String get uyumDogumEtiketi => 'Birth date';

  @override
  String get uyumRolEtiketi => 'Who are they to you?';

  @override
  String get uyumKaydet => 'Check compatibility';

  @override
  String get uyumAdBos => 'Enter a name to continue.';

  @override
  String get uyumRizaNotu =>
      'These details are stored only on this device. When you add someone else\'s details, make sure they know about it.';

  @override
  String uyumSilBaslik(String ad) {
    return 'Delete $ad?';
  }

  @override
  String get uyumSil => 'Delete';

  @override
  String get uyumVazgec => 'Cancel';

  @override
  String get uyumEtiketi => 'MATCH';

  @override
  String get uyumSonucNotu =>
      'Compatibility is calculated with traditional numerology rules from both people\'s life path numbers, zodiac elements and (if full names are known) soul numbers. It makes no judgment about the relationship\'s future; it\'s for entertainment.';

  @override
  String uyumKisiOzeti(String rol, String burc, int yasamYolu) {
    return '$rol · $burc · Life path $yasamYolu';
  }

  @override
  String get koleksiyonBaslik => 'Collection';

  @override
  String koleksiyonSayac(int kazanilan, int toplam) {
    return '$kazanilan / $toplam cards';
  }

  @override
  String koleksiyonGunSayisi(int gun) {
    String _temp0 = intl.Intl.pluralLogic(
      gun,
      locale: localeName,
      other: 'Collected on $gun different days.',
      one: 'Collected for the first time.',
    );
    return '$_temp0';
  }

  @override
  String koleksiyonIlkGun(String tarih) {
    return 'First arrived on $tarih.';
  }

  @override
  String get koleksiyonNadir => 'Rare';

  @override
  String get koleksiyonKilitliAciklama =>
      'This card hasn\'t arrived yet. Each day you open your card, a card joins your collection.';

  @override
  String get koleksiyonBosDurum =>
      'You don\'t have any cards yet. Your first card arrives when you open today\'s card.';

  @override
  String get koleksiyonBugununKarti => 'TODAY\'S CARD';

  @override
  String get koleksiyonEklendi => 'Added to your collection';

  @override
  String get koleksiyonNadirEklendi => 'Rare! Added to your collection';

  @override
  String get koleksiyonOzetAciklama =>
      'The card you open each day collects here. Rare cards arrive with a golden frame.';

  @override
  String get koleksiyonAltNot =>
      'Cards are just for fun; they don\'t affect the day\'s score or reading.';

  @override
  String get koleksiyonKartHilalKemerAd => 'Crescent Arch';

  @override
  String get koleksiyonKartHilalKemerSoz =>
      'The thin light behind the arch quietly lights your way.';

  @override
  String get koleksiyonKartIsikKapisiAd => 'Gate of Light';

  @override
  String get koleksiyonKartIsikKapisiSoz =>
      'Every door that opens is a small yes to a new beginning.';

  @override
  String get koleksiyonKartMorGeceAd => 'Violet Night';

  @override
  String get koleksiyonKartMorGeceSoz =>
      'Slowing down is moving forward too; the night nourishes all that rests.';

  @override
  String get koleksiyonKartAcikKapiAd => 'Open Door';

  @override
  String get koleksiyonKartAcikKapiSoz =>
      'The door is ajar; a single step is enough to go in.';

  @override
  String get koleksiyonKartHilalYildizAd => 'Crescent and Star';

  @override
  String get koleksiyonKartHilalYildizSoz =>
      'A small light changes the whole mood of the dark.';

  @override
  String get koleksiyonKartKoprulerAd => 'Crossing Paths';

  @override
  String get koleksiyonKartKoprulerSoz =>
      'Different paths sometimes reach the same lake.';

  @override
  String get koleksiyonKartCamFanusAd => 'Quiet Seed';

  @override
  String get koleksiyonKartCamFanusSoz =>
      'Growth is quiet; it takes root before it shows.';

  @override
  String get koleksiyonKartKagitUcakAd => 'Flying Note';

  @override
  String get koleksiyonKartKagitUcakSoz =>
      'Writing down a thought sets it on its way.';

  @override
  String get koleksiyonKartTasKuleAd => 'Balanced Stone';

  @override
  String get koleksiyonKartTasKuleSoz =>
      'Balance is setting each stone in place with patience.';

  @override
  String get koleksiyonKartDagYoluAd => 'New Trail';

  @override
  String get koleksiyonKartDagYoluSoz =>
      'The road to the mountain begins with the first step.';

  @override
  String get koleksiyonKartSonsuzlukAd => 'Returning Ribbon';

  @override
  String get koleksiyonKartSonsuzlukSoz =>
      'Some moments come back; each time they shine a little brighter.';

  @override
  String get koleksiyonKartTasKopruAd => 'Little Bridge';

  @override
  String get koleksiyonKartTasKopruSoz =>
      'You don\'t have to be big to join two shores.';

  @override
  String get koleksiyonKartDolunayAd => 'Full Moon';

  @override
  String get koleksiyonKartDolunaySoz =>
      'Every completed cycle brings a new light.';

  @override
  String get koleksiyonKartTerasAd => 'Quiet Terrace';

  @override
  String get koleksiyonKartTerasSoz =>
      'Pausing to breathe is part of the journey too.';

  @override
  String get koleksiyonKartIsikYoluAd => 'Path of Light';

  @override
  String get koleksiyonKartIsikYoluSoz =>
      'The light on the water stretches a little further with every step.';

  @override
  String get koleksiyonKartYildizYoluAd => 'Starry Path';

  @override
  String get koleksiyonKartYildizYoluSoz =>
      'A star that seems far away shows you which way to go.';

  @override
  String get koleksiyonKartAcikPencereAd => 'Open Window';

  @override
  String get koleksiyonKartAcikPencereSoz =>
      'Through an open window, a new idea comes in with the light.';

  @override
  String get koleksiyonKartYuzenFenerAd => 'Floating Lantern';

  @override
  String get koleksiyonKartYuzenFenerSoz =>
      'Even a single lantern draws its own path across the lake.';

  @override
  String get koleksiyonKartKumSaatiAd => 'Hourglass';

  @override
  String get koleksiyonKartKumSaatiSoz =>
      'Time flows; every grain is a speck of stardust.';

  @override
  String get koleksiyonKartAltinTuyAd => 'Golden Feather';

  @override
  String get koleksiyonKartAltinTuySoz =>
      'Lightness is a strength too; let go and you glide.';

  @override
  String get koleksiyonKartCamMerdivenAd => 'Glass Staircase';

  @override
  String get koleksiyonKartCamMerdivenSoz =>
      'Every step is built on the one before it.';

  @override
  String get koleksiyonKartYildizCesmesiAd => 'Star Fountain';

  @override
  String get koleksiyonKartYildizCesmesiSoz =>
      'A day like light that grows the more you share it.';

  @override
  String get koleksiyonKartAySalincagiAd => 'Moon Swing';

  @override
  String get koleksiyonKartAySalincagiSoz =>
      'A little play is the soul\'s favorite break.';

  @override
  String get koleksiyonKartPusulaAd => 'Compass';

  @override
  String get koleksiyonKartPusulaSoz =>
      'To find your way, first pause and look within.';
}
