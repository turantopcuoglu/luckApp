/// Dil bağımsız içerik erişimi (INGILIZCE_SURUM_PLANI.md §6.2, E2).
///
/// Birleştiriciler (`gunlukOkuma`, `profilOkumasi`, `haritaOkumasi` …)
/// kullanıcıya görünen adları ve dile bağlı dilbilgisi yardımcılarını bu
/// arayüzden alır; motor enum'larının Türkçe `etiket` alanlarını doğrudan
/// okumaz. Her dilin bir uygulaması vardır (`TrIcerikPaketi`; İngilizcesi
/// E7'de). Paket saf Dart'tır: `BuildContext` istemez, testlerde doğrudan
/// kurulur.
///
/// Geçiş notu: Uzun içerik havuzları (günlük okuma, rapor metinleri) bu
/// arayüze İngilizce karşılıkları yazıldıkça (E7–E9) getter olarak eklenir.
/// O zamana kadar birleştiriciler Türkçe havuzları doğrudan okur.
library;

import '../luck_engine/luck_engine.dart';
import 'okuyucu.dart';

/// İçeriğin yazıldığı dil.
///
/// Dil yalnızca metni seçer; skor, tohum ve varyant indeksleri dilden
/// bağımsızdır (değişmezler D1, D3, D5).
enum IcerikDili {
  /// Türkçe (varsayılan ve referans dil).
  tr,

  /// İngilizce.
  en,
}

/// Bir dilin içerik paketi: adlar ve dilbilgisi yardımcıları.
abstract interface class IcerikPaketi {
  /// Paketin dili.
  IcerikDili get dil;

  /// Burç adı ("Koç").
  String burcAdi(Burc burc);

  /// Element adı ("Ateş").
  String elementAdi(BurcElementi element);

  /// Şans kategorisi adı ("Aşk").
  String kategoriAdi(LuckCategory kategori);

  /// Ay evresi adı ("Dolunay").
  String ayEvresiAdi(AyEvresi evre);

  /// Uyum derecesi adı ("Güçlü uyum").
  String uyumDerecesiAdi(UyumDerecesi derece);

  /// Enerji tercihi seçenek metni.
  String enerjiTarziAdi(EnerjiTarzi tarz);

  /// Karar tercihi seçenek metni.
  String kararTarziAdi(KararTarzi tarz);

  /// İlişki durumu seçenek metni.
  String iliskiDurumuAdi(IliskiDurumu durum);

  /// Uğraş seçenek metni ("Öğrenciyim").
  String ugrasAdi(Ugras ugras);

  /// Cümle içinde özne olarak kullanılan uğraş öbeği ("derslerin").
  ///
  /// [ugras] `null` ise (soru atlandı) genel öbek döner.
  String ugrasAlani(Ugras? ugras);

  /// İsmin iyelik/ilgi biçimi: "Ayşe" → "Ayşe'nin" / "Ayşe's".
  String iyelik(String isim);
}
