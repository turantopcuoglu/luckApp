import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import '../../core/storage/uygulama_durumu.dart';
import 'magaza_servisi.dart';
import 'premium_config.dart';

/// Mağaza servisi. Üretimde `main` içinde [PlayMagazaServisi] ile
/// override edilir; override edilmezse satın alma yok.
final Provider<MagazaServisi> magazaServisiProvider =
    Provider<MagazaServisi>((Ref ref) => const BosMagazaServisi());

/// Şimdiki zaman kaynağı (testlerde sabitlenir).
final Provider<DateTime Function()> saatProvider =
    Provider<DateTime Function()>((Ref ref) => DateTime.now);

/// Premium'un anlık durumu.
@immutable
class PremiumDurumu {
  /// Tüm alanlarıyla durum oluşturur.
  const PremiumDurumu({
    this.aktif = false,
    this.islemde = false,
    this.planlar = const <AbonelikPlani>[],
    this.planlarYukleniyor = false,
    this.magazaKullanilabilir = true,
    this.hataMesaji,
  });

  /// Kullanıcının premium hakkı var mı?
  final bool aktif;

  /// Bir satın alma/geri yükleme sürüyor mu?
  final bool islemde;

  /// Mağazadan gelen planlar.
  final List<AbonelikPlani> planlar;

  /// Planlar yükleniyor mu?
  final bool planlarYukleniyor;

  /// Mağaza bu cihazda kullanılabilir mi?
  final bool magazaKullanilabilir;

  /// Kullanıcıya gösterilecek son hata (varsa).
  final String? hataMesaji;

  /// Seçili alanları değiştirilmiş kopya. [hataMesaji] her çağrıda
  /// sıfırlanır (verilmediyse null).
  PremiumDurumu copyWith({
    bool? aktif,
    bool? islemde,
    List<AbonelikPlani>? planlar,
    bool? planlarYukleniyor,
    bool? magazaKullanilabilir,
    String? hataMesaji,
  }) =>
      PremiumDurumu(
        aktif: aktif ?? this.aktif,
        islemde: islemde ?? this.islemde,
        planlar: planlar ?? this.planlar,
        planlarYukleniyor: planlarYukleniyor ?? this.planlarYukleniyor,
        magazaKullanilabilir: magazaKullanilabilir ?? this.magazaKullanilabilir,
        hataMesaji: hataMesaji,
      );
}

/// Premium abonelik durumunu yöneten tek kontrolcü.
///
/// Doğruluk kaynağı Google Play'dir: her açılışta satın alımlar geri
/// yüklenir ve sonuç önbelleğe yazılır. Mağazaya ulaşılamazsa önbellekteki
/// aktif durum [PremiumConfig.cevrimdisiTolerans] boyunca geçerli sayılır.
///
/// Not: Sunucu tarafı makbuz doğrulaması yoktur (uygulamanın backend'i
/// yok). Kötüye kullanıma karşı ileride Play Developer API ile sunucu
/// doğrulaması eklenebilir; bu sınıfın dışa açık yüzü değişmez.
class PremiumKontrolcu extends Notifier<PremiumDurumu> {
  StreamSubscription<List<SatinAlmaGuncellemesi>>? _abonelik;
  bool _geriYuklemeBekleniyor = false;

  UygulamaDurumuRepository get _depo =>
      ref.read(uygulamaDurumuRepositoryProvider);

  @override
  PremiumDurumu build() {
    ref.onDispose(() => _abonelik?.cancel());
    return PremiumDurumu(aktif: _onbellektenAktifMi(_depo.durum));
  }

  bool _onbellektenAktifMi(UygulamaDurumu durum) {
    if (kDebugMode && durum.gelistiriciPremium) {
      return true;
    }
    final DateTime? dogrulama = durum.premiumDogrulama;
    if (!durum.premiumAktif || dogrulama == null) {
      return false;
    }
    return ref.read(saatProvider)().difference(dogrulama) <=
        PremiumConfig.cevrimdisiTolerans;
  }

  /// Mağazayı dinlemeye başlar, satın alımları geri yükler ve planları
  /// getirir. Uygulama açılışında bir kez çağrılır.
  Future<void> baslat() async {
    final MagazaServisi magaza = ref.read(magazaServisiProvider);
    _abonelik ??= magaza.guncellemeler.listen(
      _guncellemeleriIsle,
      onError: (Object hata) => debugPrint('Satın alma akışı hatası: $hata'),
    );
    final bool kullanilabilir = await magaza.kullanilabilirMi();
    state = state.copyWith(magazaKullanilabilir: kullanilabilir);
    if (!kullanilabilir) {
      return;
    }
    await geriYukle(sessiz: true);
    await planlariYukle();
  }

  /// Planları mağazadan (yeniden) yükler.
  Future<void> planlariYukle() async {
    state = state.copyWith(planlarYukleniyor: true);
    try {
      final List<AbonelikPlani> planlar =
          await ref.read(magazaServisiProvider).planlariGetir();
      state = state.copyWith(planlar: planlar, planlarYukleniyor: false);
    } on Exception catch (hata) {
      debugPrint('Planlar yüklenemedi: $hata');
      state = state.copyWith(
        planlarYukleniyor: false,
        hataMesaji: PremiumHatalari.planlarYuklenemedi,
      );
    }
  }

  /// [plan] için satın alma akışını başlatır.
  Future<void> satinAl(AbonelikPlani plan) async {
    state = state.copyWith(islemde: true);
    final bool basladi = await ref.read(magazaServisiProvider).satinAl(plan);
    if (!basladi) {
      state = state.copyWith(
        islemde: false,
        hataMesaji: PremiumHatalari.satinAlmaBaslamadi,
      );
    }
  }

  /// Satın alımları geri yükler. [sessiz] ise hata mesajı gösterilmez.
  Future<void> geriYukle({bool sessiz = false}) async {
    _geriYuklemeBekleniyor = true;
    if (!sessiz) {
      state = state.copyWith(islemde: true);
    }
    try {
      await ref.read(magazaServisiProvider).geriYukle();
    } on Exception catch (hata) {
      debugPrint('Geri yükleme hatası: $hata');
      _geriYuklemeBekleniyor = false;
      state = state.copyWith(
        islemde: false,
        hataMesaji: sessiz ? null : PremiumHatalari.geriYuklenemedi,
      );
    }
  }

  Future<void> _guncellemeleriIsle(List<SatinAlmaGuncellemesi> liste) async {
    final MagazaServisi magaza = ref.read(magazaServisiProvider);
    final DateTime simdi = ref.read(saatProvider)();
    bool aktifBulundu = false;
    String? aktifUrun;
    String? hata;

    for (final SatinAlmaGuncellemesi g in liste) {
      final bool bizim = PremiumConfig.urunKimlikleri.contains(g.urunId);
      switch (g.durum) {
        case SatinAlmaDurumu.satinAlindi:
        case SatinAlmaDurumu.geriYuklendi:
          if (bizim) {
            aktifBulundu = true;
            aktifUrun = g.urunId;
          }
        case SatinAlmaDurumu.hata:
          hata = PremiumHatalari.satinAlmaHatasi;
        case SatinAlmaDurumu.beklemede:
          hata = PremiumHatalari.odemeBekleniyor;
        case SatinAlmaDurumu.iptal:
          break;
      }
      // Teslim edilen her satın alma mağazaya onaylanmalı; aksi halde
      // Google Play 3 gün sonra otomatik iade eder.
      if (g.tamamlanmaBekliyor) {
        await magaza.tamamla(g);
      }
    }

    final bool geriYuklemeSonucu = _geriYuklemeBekleniyor;
    _geriYuklemeBekleniyor = false;

    // Durum önce güncellenir, önbellek sonra yazılır: disk yazması
    // sürerken gelen yeni bir olay, eski bir sonucun üzerine yazılmasın.
    if (aktifBulundu) {
      state = state.copyWith(aktif: true, islemde: false);
      await _depo.premiumuKaydet(
        aktif: true,
        dogrulama: simdi,
        urunId: aktifUrun,
      );
      return;
    }
    if (geriYuklemeSonucu) {
      // Geri yükleme listesinde aktif abonelik yok: süresi dolmuş ya da
      // iptal edilmiş. Debug simülasyonu açıksa ona dokunulmaz.
      state = state.copyWith(
        aktif: kDebugMode && _depo.durum.gelistiriciPremium,
        islemde: false,
        hataMesaji: hata,
      );
      await _depo.premiumuKaydet(aktif: false, dogrulama: simdi);
      return;
    }
    state = state.copyWith(islemde: false, hataMesaji: hata);
  }

  /// Yalnızca debug derlemede: premium simülasyonunu aç/kapat.
  Future<void> gelistiriciPremiumAyarla({required bool acik}) async {
    if (!kDebugMode) {
      return;
    }
    await _depo.gelistiriciPremiumAyarla(acik: acik);
    state = state.copyWith(aktif: _onbellektenAktifMi(_depo.durum));
  }

  /// Gösterilen hata mesajını temizler.
  void hatayiTemizle() => state = state.copyWith();
}

/// Premium akışının kullanıcıya dönük hata metinleri.
abstract final class PremiumHatalari {
  /// Planlar yüklenemedi.
  static const String planlarYuklenemedi =
      'Abonelik seçenekleri şu an yüklenemedi. İnternet bağlantını kontrol '
      'edip tekrar dene.';

  /// Satın alma akışı başlamadı.
  static const String satinAlmaBaslamadi =
      'Satın alma başlatılamadı. Google Play hesabının açık olduğundan emin '
      'olup tekrar dene.';

  /// Satın alma sırasında hata.
  static const String satinAlmaHatasi =
      'Satın alma tamamlanamadı. Ücret alınmadıysa tekrar deneyebilirsin.';

  /// Ödeme beklemede.
  static const String odemeBekleniyor =
      'Ödemen onay bekliyor. Onaylandığında Premium otomatik açılacak.';

  /// Geri yükleme hatası.
  static const String geriYuklenemedi =
      'Satın alımlar geri yüklenemedi. Aynı Google hesabıyla giriş yaptığından '
      'emin ol.';
}

/// Premium kontrolcüsü.
final NotifierProvider<PremiumKontrolcu, PremiumDurumu>
    premiumKontrolcuProvider =
    NotifierProvider<PremiumKontrolcu, PremiumDurumu>(PremiumKontrolcu.new);
