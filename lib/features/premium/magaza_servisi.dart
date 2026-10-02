import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'premium_config.dart';

/// Satın alınabilir bir abonelik planı (mağazadan bağımsız temsil).
class AbonelikPlani {
  /// Tüm alanlarıyla plan oluşturur.
  const AbonelikPlani({
    required this.urunId,
    required this.fiyatMetni,
    required this.hamFiyat,
    required this.yillikMi,
    this.denemeGunu,
    this.ham,
  });

  /// Mağaza ürün kimliği.
  final String urunId;

  /// Yerelleştirilmiş, yinelenen dönem fiyatı ("₺449,99").
  final String fiyatMetni;

  /// Sayısal fiyat (aylık karşılık hesabı için).
  final double hamFiyat;

  /// Yıllık plan mı?
  final bool yillikMi;

  /// Varsa ücretsiz deneme süresi (gün).
  final int? denemeGunu;

  /// Mağazaya özgü ham ürün nesnesi (satın alma için).
  final Object? ham;
}

/// Satın alınabilir tek seferlik (süresiz) bir ürün.
class TekSeferlikUrun {
  /// Tüm alanlarıyla ürün oluşturur.
  const TekSeferlikUrun({
    required this.urunId,
    required this.fiyatMetni,
    this.ham,
  });

  /// Mağaza ürün kimliği.
  final String urunId;

  /// Yerelleştirilmiş fiyat ("₺149,99").
  final String fiyatMetni;

  /// Mağazaya özgü ham ürün nesnesi (satın alma için).
  final Object? ham;
}

/// Mağazadan gelen satın alma olayının durumu.
enum SatinAlmaDurumu {
  /// Ödeme bekleniyor (ör. nakit ödeme yöntemi).
  beklemede,

  /// Yeni satın alma tamamlandı.
  satinAlindi,

  /// Önceki satın alma geri yüklendi.
  geriYuklendi,

  /// Kullanıcı vazgeçti.
  iptal,

  /// Hata oluştu.
  hata,
}

/// Tek bir satın alma güncellemesi.
class SatinAlmaGuncellemesi {
  /// Tüm alanlarıyla güncelleme oluşturur.
  const SatinAlmaGuncellemesi({
    required this.urunId,
    required this.durum,
    required this.tamamlanmaBekliyor,
    this.hataMesaji,
    this.ham,
  });

  /// Ürün kimliği.
  final String urunId;

  /// Durum.
  final SatinAlmaDurumu durum;

  /// Mağazaya "teslim edildi" bildirimi (acknowledge) gerekiyor mu?
  ///
  /// Google Play'de onaylanmayan satın alımlar 3 gün içinde iade edilir.
  final bool tamamlanmaBekliyor;

  /// Hata durumunda mesaj.
  final String? hataMesaji;

  /// Mağazaya özgü ham nesne (tamamlama çağrısı için).
  final Object? ham;
}

/// Uygulama içi satın alma altyapısının soyutlaması.
abstract class MagazaServisi {
  /// Satın alma güncellemeleri akışı. Geri yükleme sonuçları da buradan
  /// (boş liste dahil) gelir.
  Stream<List<SatinAlmaGuncellemesi>> get guncellemeler;

  /// Mağaza bu cihazda kullanılabilir mi?
  Future<bool> kullanilabilirMi();

  /// Tanımlı abonelik planlarını getirir (bulunamayanlar atlanır).
  Future<List<AbonelikPlani>> planlariGetir();

  /// [plan] için satın alma akışını başlatır; akış başladıysa true.
  Future<bool> satinAl(AbonelikPlani plan);

  /// [urunId] kimlikli tek seferlik ürünü getirir; bulunamazsa null.
  Future<TekSeferlikUrun?> tekSeferlikUrunGetir(String urunId);

  /// [urun] için tek seferlik satın alma akışını başlatır; akış başladıysa
  /// true.
  Future<bool> tekSeferlikSatinAl(TekSeferlikUrun urun);

  /// Önceki satın alımları geri yükler (sonuç [guncellemeler]'den gelir).
  Future<void> geriYukle();

  /// Teslim edilen satın almayı mağazaya onaylar.
  Future<void> tamamla(SatinAlmaGuncellemesi guncelleme);
}

/// Mağazası olmayan ortam (testler, desteklenmeyen platformlar).
class BosMagazaServisi implements MagazaServisi {
  /// Varsayılan kurucu.
  const BosMagazaServisi();

  @override
  Stream<List<SatinAlmaGuncellemesi>> get guncellemeler =>
      const Stream<List<SatinAlmaGuncellemesi>>.empty();

  @override
  Future<bool> kullanilabilirMi() async => false;

  @override
  Future<List<AbonelikPlani>> planlariGetir() async => const <AbonelikPlani>[];

  @override
  Future<bool> satinAl(AbonelikPlani plan) async => false;

  @override
  Future<TekSeferlikUrun?> tekSeferlikUrunGetir(String urunId) async => null;

  @override
  Future<bool> tekSeferlikSatinAl(TekSeferlikUrun urun) async => false;

  @override
  Future<void> geriYukle() async {}

  @override
  Future<void> tamamla(SatinAlmaGuncellemesi guncelleme) async {}
}

/// Google Play Faturalandırma (in_app_purchase) uygulaması.
class PlayMagazaServisi implements MagazaServisi {
  /// [iap] verilmezse eklentinin tekil örneği kullanılır.
  PlayMagazaServisi({InAppPurchase? iap})
    : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  @override
  Stream<List<SatinAlmaGuncellemesi>> get guncellemeler =>
      _iap.purchaseStream.map(
        (List<PurchaseDetails> liste) => <SatinAlmaGuncellemesi>[
          for (final PurchaseDetails p in liste) _cevir(p),
        ],
      );

  SatinAlmaGuncellemesi _cevir(PurchaseDetails p) => SatinAlmaGuncellemesi(
    urunId: p.productID,
    durum: switch (p.status) {
      PurchaseStatus.pending => SatinAlmaDurumu.beklemede,
      PurchaseStatus.purchased => SatinAlmaDurumu.satinAlindi,
      PurchaseStatus.restored => SatinAlmaDurumu.geriYuklendi,
      PurchaseStatus.canceled => SatinAlmaDurumu.iptal,
      PurchaseStatus.error => SatinAlmaDurumu.hata,
    },
    tamamlanmaBekliyor: p.pendingCompletePurchase,
    hataMesaji: p.error?.message,
    ham: p,
  );

  @override
  Future<bool> kullanilabilirMi() async {
    try {
      return await _iap.isAvailable();
    } on PlatformException catch (hata) {
      debugPrint('Mağaza kontrol edilemedi: $hata');
      return false;
    }
  }

  @override
  Future<List<AbonelikPlani>> planlariGetir() async {
    final ProductDetailsResponse cevap = await _iap.queryProductDetails(
      PremiumConfig.urunKimlikleri.toSet(),
    );
    if (cevap.error != null) {
      debugPrint('Ürünler alınamadı: ${cevap.error!.message}');
    }
    final List<AbonelikPlani> planlar = <AbonelikPlani>[];
    for (final String urunId in PremiumConfig.urunKimlikleri) {
      final List<ProductDetails> teklifler = cevap.productDetails
          .where((ProductDetails d) => d.id == urunId)
          .toList();
      if (teklifler.isEmpty) {
        continue;
      }
      planlar.add(_planKur(urunId, teklifler));
    }
    return planlar;
  }

  /// Bir aboneliğin teklifleri arasından satın alınacak olanı seçer.
  ///
  /// Play her temel plan ve kullanıcının UYGUN olduğu her teklif için ayrı
  /// bir kayıt döndürür. Ücretsiz deneme içeren teklif varsa o seçilir
  /// (kullanıcı uygun değilse Play onu zaten listelemez); gösterilen fiyat
  /// her zaman yinelenen dönemin (son fiyat aşamasının) fiyatıdır.
  AbonelikPlani _planKur(String urunId, List<ProductDetails> teklifler) {
    ProductDetails secilen = teklifler.first;
    int? denemeGunu;
    String fiyat = secilen.price;
    double hamFiyat = secilen.rawPrice;

    for (final ProductDetails d in teklifler) {
      if (d is! GooglePlayProductDetails || d.subscriptionIndex == null) {
        continue;
      }
      final SubscriptionOfferDetailsWrapper teklif =
          d.productDetails.subscriptionOfferDetails![d.subscriptionIndex!];
      final PricingPhaseWrapper yinelenen = teklif.pricingPhases.last;
      fiyat = yinelenen.formattedPrice;
      hamFiyat = yinelenen.priceAmountMicros / 1000000;
      final PricingPhaseWrapper ilk = teklif.pricingPhases.first;
      if (ilk.priceAmountMicros == 0 && teklif.pricingPhases.length > 1) {
        secilen = d;
        denemeGunu = _gunSayisi(ilk.billingPeriod);
      }
    }
    return AbonelikPlani(
      urunId: urunId,
      fiyatMetni: fiyat,
      hamFiyat: hamFiyat,
      yillikMi: urunId == PremiumConfig.yillikUrunId,
      denemeGunu: denemeGunu,
      ham: secilen,
    );
  }

  /// ISO-8601 süresini ("P7D", "P1W", "P1M") yaklaşık güne çevirir.
  static int? _gunSayisi(String sure) {
    final RegExpMatch? m = RegExp(r'^P(\d+)([DWMY])$').firstMatch(sure);
    if (m == null) {
      return null;
    }
    final int n = int.parse(m.group(1)!);
    const Map<String, int> carpan = <String, int>{
      'D': 1,
      'W': 7,
      'M': 30,
      'Y': 365,
    };
    return n * carpan[m.group(2)]!;
  }

  @override
  Future<bool> satinAl(AbonelikPlani plan) async {
    final Object? ham = plan.ham;
    if (ham is! ProductDetails) {
      return false;
    }
    final PurchaseParam param = ham is GooglePlayProductDetails
        ? GooglePlayPurchaseParam(
            productDetails: ham,
            offerToken: ham.offerToken,
          )
        : PurchaseParam(productDetails: ham);
    try {
      // Abonelikler Play'de "non-consumable" akışıyla satın alınır.
      return await _iap.buyNonConsumable(purchaseParam: param);
    } on PlatformException catch (hata) {
      debugPrint('Satın alma başlatılamadı: $hata');
      return false;
    }
  }

  @override
  Future<TekSeferlikUrun?> tekSeferlikUrunGetir(String urunId) async {
    final ProductDetailsResponse cevap = await _iap.queryProductDetails(
      <String>{urunId},
    );
    if (cevap.error != null) {
      debugPrint('Ürün alınamadı: ${cevap.error!.message}');
    }
    for (final ProductDetails d in cevap.productDetails) {
      if (d.id == urunId) {
        return TekSeferlikUrun(urunId: urunId, fiyatMetni: d.price, ham: d);
      }
    }
    return null;
  }

  @override
  Future<bool> tekSeferlikSatinAl(TekSeferlikUrun urun) async {
    final Object? ham = urun.ham;
    if (ham is! ProductDetails) {
      return false;
    }
    try {
      // Tek seferlik ve süresiz: tüketilmez, geri yüklemede yeniden gelir.
      return await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: ham),
      );
    } on PlatformException catch (hata) {
      debugPrint('Satın alma başlatılamadı: $hata');
      return false;
    }
  }

  @override
  Future<void> geriYukle() => _iap.restorePurchases();

  @override
  Future<void> tamamla(SatinAlmaGuncellemesi guncelleme) async {
    final Object? ham = guncelleme.ham;
    if (ham is PurchaseDetails) {
      await _iap.completePurchase(ham);
    }
  }
}
