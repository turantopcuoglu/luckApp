import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart';
import '../../core/content/gunluk_okuma.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/daily_record.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../features/daily_luck/daily_luck_config.dart';

/// Uygulamanın "bugün" saydığı an ve onu yeni güne ilerleten kontrolcü.
///
/// Açılışta cihaz saatinden kurulur. Uygulama bellekte açık kalıp ertesi
/// gün öne geldiğinde ya da gece yarısı ekrandayken [tazele] çağrılır
/// (bkz. `GunDevriGozcusu`); takvim günü değiştiyse durum yenilenir ve
/// [bugunProvider]'ı izleyen her şey (günün skoru, okuma, reklamla açılan
/// günlük kilitler…) yeni güne geçer. Eskiden tarih yalnızca açılışta
/// okunuyor, uygulamayı kapatmayan kullanıcı ertesi sabah dünün kartını
/// görüyordu.
class GunDevri extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  /// [simdi] farklı bir takvim günündeyse günü ona ilerletir ve true
  /// döner; aynı gündeyse hiçbir şey değişmez (izleyen provider'lar boşuna
  /// yeniden hesaplanmasın, açılmış kart kapanmasın).
  bool tazele(DateTime simdi) {
    if (_ayniGun(state, simdi)) {
      return false;
    }
    state = simdi;
    return true;
  }
}

/// [a] ve [b] aynı takvim gününde mi?
bool _ayniGun(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// [GunDevri] kontrolcüsünün provider'ı.
final NotifierProvider<GunDevri, DateTime> gunDevriProvider =
    NotifierProvider<GunDevri, DateTime>(GunDevri.new);

/// Bugünün tarihini sağlar.
///
/// Üretimde [gunDevriProvider]'ı izler: gün değişince kendiliğinden
/// yenilenir. Testlerde sabit bir güne override edilir.
final Provider<DateTime> bugunProvider = Provider<DateTime>(
  (Ref ref) => ref.watch(gunDevriProvider),
);

/// Akşam oldu mu: akşam geri bildirim kartının saati
/// ([DailyLuckConfig.aksamKartiSaati]) geldi mi?
///
/// Başlangıçta [bugunProvider]'ın saatinden kurulur; gün değişince
/// kendiliğinden yeniden kurulur. Gün içinde [tazele] ile güncellenir
/// (bkz. `GunDevriGozcusu`): uygulamayı sabah açıp akşam geri dönen kişi
/// kartı görür. [bugunProvider]'dan ayrı tutulur, çünkü "bugün"ü gün
/// içinde değiştirmek günün skorunu ve okumasını yeniden yükletir, açılmış
/// kartı kapatırdı.
class AksamDevri extends Notifier<bool> {
  @override
  bool build() => _aksamMi(ref.watch(bugunProvider));

  /// [simdi] bugünün içindeyse akşam durumunu ona göre günceller; başka
  /// bir gündeyse dokunmaz (gün değişimi [GunDevri.tazele]'nin işidir).
  void tazele(DateTime simdi) {
    if (_ayniGun(ref.read(bugunProvider), simdi)) {
      state = _aksamMi(simdi);
    }
  }

  static bool _aksamMi(DateTime an) =>
      an.hour >= DailyLuckConfig.aksamKartiSaati;
}

/// [AksamDevri] kontrolcüsünün provider'ı.
final NotifierProvider<AksamDevri, bool> aksamOlduProvider =
    NotifierProvider<AksamDevri, bool>(AksamDevri.new);

/// Aktif kullanıcı profili.
///
/// Onboarding tamamlanana kadar kayıtlı profil yoksa misafir profiline
/// düşer; böylece ekran her koşulda çalışır. Profil düzenlendiğinde
/// yazan taraf bu provider'ı invalidate eder.
final Provider<UserProfile> aktifProfilProvider = Provider<UserProfile>(
  (Ref ref) =>
      ref.watch(userRepositoryProvider).profil() ??
      UserProfile(
        isim: DailyLuckConfig.misafirIsmi,
        // Misafir için sabit doğum tarihi: deterministik skor üretimi
        // isteyen kural 8 gereği rastgele bir değer KULLANILAMAZ.
        dogumTarihi: DateTime(2000),
      ),
);

/// Bugünün şans sonucu.
///
/// Kayıt varsa depodan okur, yoksa motorla üretip saklar; aynı gün
/// içinde motor ikinci kez çalıştırılmaz (Session 2 garantisi).
final FutureProvider<LuckResult> gununSansiProvider =
    FutureProvider<LuckResult>((Ref ref) {
  return ref.watch(luckHistoryRepositoryProvider).getirVeyaUret(
        motor: ref.watch(luckEngineProvider),
        kullanici: ref.watch(aktifProfilProvider).seed,
        gun: ref.watch(bugunProvider),
      );
});

/// Bugünün kişiye özel, bölümlü okuması.
///
/// Persist edilmez; saklanan [LuckResult] + sabit profil + ÖNCEKİ
/// günlerin bölüm geri bildirimlerinden her açılışta aynı şekilde
/// yeniden türetilir (kural 8). Bugün verilen geri bildirim bugünün
/// metnini değiştirmez.
final FutureProvider<GunlukOkuma> gunlukOkumaProvider =
    FutureProvider<GunlukOkuma>((Ref ref) async {
  final LuckResult sonuc = await ref.watch(gununSansiProvider.future);
  return gunlukOkuma(
    motor: ref.watch(luckEngineProvider),
    okuyucu: ref.watch(aktifProfilProvider).okuyucu,
    sonuc: sonuc,
    begenilmeyenler: ref
        .watch(luckHistoryRepositoryProvider)
        .begenilmeyenKimlikler(once: ref.watch(bugunProvider)),
  );
});

/// Bugünün beş kategori okuması.
///
/// Ana ekrandaki kategori satırları bunun kısa başlığını gösterir
/// (kilitli kategoride de: merak uyandıran önizleme), kilit sayfası da
/// aynı başlığı önizleme olarak kullanır. Detay sayfasıyla AYNI
/// fonksiyondan türediği için satırdaki başlık detayda okunanla aynıdır.
final FutureProvider<Map<LuckCategory, KategoriOkumasi>>
kategoriOkumalariProvider = FutureProvider<Map<LuckCategory, KategoriOkumasi>>(
  (Ref ref) async {
    final LuckResult sonuc = await ref.watch(gununSansiProvider.future);
    final LuckEngine motor = ref.watch(luckEngineProvider);
    final UserProfile profil = ref.watch(aktifProfilProvider);
    return <LuckCategory, KategoriOkumasi>{
      for (final LuckCategory k in LuckCategory.values)
        k: kategoriOkumasi(
          motor: motor,
          okuyucu: profil.okuyucu,
          sonuc: sonuc,
          kategori: k,
        ),
    };
  },
);

/// Bugünün kaydı (bölüm cevapları ve akşam geri bildirimi için).
///
/// Yazan taraf invalidate eder; kayıt henüz yoksa null. Günün sonucu
/// üretilip kaydedildiğinde de yeniden okunsun diye onu dinler.
final Provider<DailyRecord?> bugunKaydiProvider = Provider<DailyRecord?>(
  (Ref ref) {
    ref.watch(gununSansiProvider);
    return ref
        .watch(luckHistoryRepositoryProvider)
        .getir(ref.watch(bugunProvider));
  },
);
