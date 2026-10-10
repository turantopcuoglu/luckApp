import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import '../../core/storage/uygulama_durumu.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/dil_providers.dart';
import 'magaza_servisi.dart';
import 'premium_config.dart';

/// Mağaza servisi. Üretimde `main` içinde [PlayMagazaServisi] ile
/// override edilir; override edilmezse satın alma yok.
final Provider<MagazaServisi> magazaServisiProvider = Provider<MagazaServisi>(
  (Ref ref) => const BosMagazaServisi(),
);

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
    this.sahipOlunanlar = const <String>{},
    this.tekSeferlikUrunler = const <String, TekSeferlikUrun>{},
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

  /// Kullanıcının sahip olduğu tek seferlik ürünlerin kimlikleri
  /// (Numeroloji Raporu, yıl raporları).
  ///
  /// Premium yetkisi DEĞİLDİR; yalnızca ilgili raporun kilidini açar.
  final Set<String> sahipOlunanlar;

  /// Mağazadan fiyatıyla yüklenen tek seferlik ürünler (kimlik → ürün).
  final Map<String, TekSeferlikUrun> tekSeferlikUrunler;

  /// Kullanıcı [urunId] tek seferlik ürününe sahip mi?
  bool sahipMi(String urunId) => sahipOlunanlar.contains(urunId);

  /// Kullanıcı Numeroloji Raporu'nu satın almış mı?
  bool get raporSahibi => sahipMi(PremiumConfig.raporUrunId);

  /// Mağazadan gelen Numeroloji Raporu ürünü (yoksa null).
  TekSeferlikUrun? get raporUrunu =>
      tekSeferlikUrunler[PremiumConfig.raporUrunId];

  /// Seçili alanları değiştirilmiş kopya. [hataMesaji] her çağrıda
  /// sıfırlanır (verilmediyse null).
  PremiumDurumu copyWith({
    bool? aktif,
    bool? islemde,
    List<AbonelikPlani>? planlar,
    bool? planlarYukleniyor,
    bool? magazaKullanilabilir,
    String? hataMesaji,
    Set<String>? sahipOlunanlar,
    Map<String, TekSeferlikUrun>? tekSeferlikUrunler,
  }) => PremiumDurumu(
    aktif: aktif ?? this.aktif,
    islemde: islemde ?? this.islemde,
    planlar: planlar ?? this.planlar,
    planlarYukleniyor: planlarYukleniyor ?? this.planlarYukleniyor,
    magazaKullanilabilir: magazaKullanilabilir ?? this.magazaKullanilabilir,
    hataMesaji: hataMesaji,
    sahipOlunanlar: sahipOlunanlar ?? this.sahipOlunanlar,
    tekSeferlikUrunler: tekSeferlikUrunler ?? this.tekSeferlikUrunler,
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
  /// Hata mesajlarının dili (uygulama dili; kontrolcü widget ağacının
  /// dışında çalıştığı için `BuildContext` yerine provider'dan okunur).
  AppLocalizations get _metinler => ref.read(arayuzMetinleriProvider);

  StreamSubscription<List<SatinAlmaGuncellemesi>>? _abonelik;
  bool _geriYuklemeBekleniyor = false;

  UygulamaDurumuRepository get _depo =>
      ref.read(uygulamaDurumuRepositoryProvider);

  @override
  PremiumDurumu build() {
    ref.onDispose(() => _abonelik?.cancel());
    final UygulamaDurumu durum = _depo.durum;
    return PremiumDurumu(
      aktif: _onbellektenAktifMi(durum),
      sahipOlunanlar: durum.sahipOlunanUrunler,
    );
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
    await tekSeferlikUrunleriYukle();
  }

  /// Satıştaki tek seferlik ürünleri (fiyatlarıyla) mağazadan yükler;
  /// bulunamayanlar atlanır.
  Future<void> tekSeferlikUrunleriYukle() async {
    final MagazaServisi magaza = ref.read(magazaServisiProvider);
    final Map<String, TekSeferlikUrun> urunler = <String, TekSeferlikUrun>{
      ...state.tekSeferlikUrunler,
    };
    for (final String urunId in PremiumConfig.satistakiTekSeferlikler) {
      try {
        final TekSeferlikUrun? urun = await magaza.tekSeferlikUrunGetir(urunId);
        if (urun != null) {
          urunler[urunId] = urun;
        }
      } on Exception catch (hata) {
        debugPrint('$urunId yüklenemedi: $hata');
      }
    }
    state = state.copyWith(tekSeferlikUrunler: urunler);
  }

  /// [urunId] tek seferlik ürünü için satın alma akışını başlatır.
  ///
  /// Ürün henüz yüklenmediyse önce yüklemeyi dener.
  Future<void> tekSeferlikSatinAl(String urunId) async {
    if (!state.tekSeferlikUrunler.containsKey(urunId)) {
      await tekSeferlikUrunleriYukle();
    }
    final TekSeferlikUrun? urun = state.tekSeferlikUrunler[urunId];
    if (urun == null) {
      state = state.copyWith(hataMesaji: _metinler.premiumHataRaporUrunuYok);
      return;
    }
    state = state.copyWith(islemde: true);
    final bool basladi = await ref
        .read(magazaServisiProvider)
        .tekSeferlikSatinAl(urun);
    if (!basladi) {
      state = state.copyWith(
        islemde: false,
        hataMesaji: _metinler.premiumHataSatinAlmaBaslamadi,
      );
    }
  }

  /// Planları mağazadan (yeniden) yükler.
  Future<void> planlariYukle() async {
    state = state.copyWith(planlarYukleniyor: true);
    try {
      final List<AbonelikPlani> planlar = await ref
          .read(magazaServisiProvider)
          .planlariGetir();
      state = state.copyWith(planlar: planlar, planlarYukleniyor: false);
    } on Exception catch (hata) {
      debugPrint('Planlar yüklenemedi: $hata');
      state = state.copyWith(
        planlarYukleniyor: false,
        hataMesaji: _metinler.premiumHataPlanlar,
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
        hataMesaji: _metinler.premiumHataSatinAlmaBaslamadi,
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
        hataMesaji: sessiz ? null : _metinler.premiumHataGeriYukleme,
      );
    }
  }

  Future<void> _guncellemeleriIsle(List<SatinAlmaGuncellemesi> liste) async {
    final MagazaServisi magaza = ref.read(magazaServisiProvider);
    final DateTime simdi = ref.read(saatProvider)();
    // Depo, beklemelerden ÖNCE alınır: mağaza onayı ve disk yazmaları
    // sürerken kontrolcü kapanırsa (ör. ekran/test sonu) ref artık
    // okunamaz.
    final UygulamaDurumuRepository depo = _depo;
    bool aktifBulundu = false;
    final Set<String> bulunanTekSeferlikler = <String>{};
    String? aktifUrun;
    String? hata;

    for (final SatinAlmaGuncellemesi g in liste) {
      final bool abonelik = PremiumConfig.urunKimlikleri.contains(g.urunId);
      switch (g.durum) {
        case SatinAlmaDurumu.satinAlindi:
        case SatinAlmaDurumu.geriYuklendi:
          if (abonelik) {
            aktifBulundu = true;
            aktifUrun = g.urunId;
          } else if (PremiumConfig.tekSeferlikMi(g.urunId)) {
            bulunanTekSeferlikler.add(g.urunId);
          }
        case SatinAlmaDurumu.hata:
          hata = _metinler.premiumHataSatinAlma;
        case SatinAlmaDurumu.beklemede:
          hata = _metinler.premiumHataOdemeBekleniyor;
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

    // Abonelik: satın alındı/geri yüklendiyse açık; geri yükleme listesinde
    // yoksa süresi dolmuş ya da iptal edilmiş (debug simülasyonu korunur).
    // Tek seferlik ürünler: geri yükleme listesi sahipliklerin tamamıdır
    // (listede olmayan iade edilmiştir); satın alma olayı ise listeye ekler.
    // Diğer olaylarda (ör. yalnızca hata) iki durum da değişmez.
    final bool? yeniAktif = aktifBulundu
        ? true
        : (geriYuklemeSonucu
              ? kDebugMode && depo.durum.gelistiriciPremium
              : null);
    final Set<String>? yeniSahiplikler = geriYuklemeSonucu
        ? bulunanTekSeferlikler
        : (bulunanTekSeferlikler.isEmpty
              ? null
              : <String>{...state.sahipOlunanlar, ...bulunanTekSeferlikler});

    // Durum önce güncellenir, önbellek sonra yazılır: disk yazması
    // sürerken gelen yeni bir olay, eski bir sonucun üzerine yazılmasın.
    state = state.copyWith(
      aktif: yeniAktif,
      sahipOlunanlar: yeniSahiplikler,
      islemde: false,
      hataMesaji: aktifBulundu || bulunanTekSeferlikler.isNotEmpty
          ? null
          : hata,
    );
    if (aktifBulundu) {
      await depo.premiumuKaydet(
        aktif: true,
        dogrulama: simdi,
        urunId: aktifUrun,
      );
    } else if (geriYuklemeSonucu) {
      await depo.premiumuKaydet(aktif: false, dogrulama: simdi);
    }
    if (yeniSahiplikler != null) {
      // Hesaplanan küme değil, yazma anındaki GÜNCEL durum yazılır: önceki
      // bir olayın (ör. açılış geri yüklemesi) disk yazması sürerken gelen
      // satın alma, geç biten eski yazmayla önbellekten silinmesin.
      await depo.tekSeferlikleriKaydet(state.sahipOlunanlar);
    }
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

/// Premium kontrolcüsü.
final NotifierProvider<PremiumKontrolcu, PremiumDurumu>
premiumKontrolcuProvider = NotifierProvider<PremiumKontrolcu, PremiumDurumu>(
  PremiumKontrolcu.new,
);
