import 'sans_rengi.dart';

/// Günlük okumanın yorumdan bağımsız havuzları: günün tavsiyesi ve şans
/// rengi.
///
/// Her tavsiye kendi başına tam bir cümledir. Ton: falcı sesi — mistik
/// ama sıcak, ikinci tekil şahıs, somut imgeler; sayı/yüzde/mekanik
/// ifade yok.
abstract final class FortunePools {
  /// Yorumdan bağımsız günün tavsiyeleri.
  static const List<String> gununTavsiyeleri = <String>[
    'Bugün ilk hissettiğine güven; ikinci tahmin şansı kaçırır.',
    'Cebinde taşıdığın küçük bir nesne bugün sana uğur getirecek.',
    'Bugün birine beklemediği bir iltifat et; yankısı sana döner.',
    'Gün içinde beş dakikalık bir sessizlik bugün zihnini toplar.',
    'Bugün eski bir fotoğrafa bak; hatırladığın şey yol gösterecek.',
    'Pencereni sabah ilk iş aç; taze hava bugünkü şansını içeri alır.',
    'Bugün su iç, çok iç; berrak zihin berrak talih çeker.',
    'Ertelediğin küçük işi bugün bitir; ferahlığı akşamı güzelleştirir.',
    'Bugün yeşil gördüğün yerde bir nefes dur; toprak enerji verir.',
    'Kalabalıkta ismini duyarsan bugün gülümse; iyi haber yakındır.',
    'Bugün defterine tek cümle yaz; yıl sonunda kehanet gibi okunur.',
    'Ayakkabılarını bugün özenle bağla; sağlam adım sağlam gün getirir.',
    'Bugün tanımadığın birine yol ver; açtığın yol sana geri açılır.',
    'Akşam gökyüzüne bir kez bak; ilk gördüğün yıldıza dileğini bırak.',
    'Bugün müzik aç ve bir şarkıyı sonuna kadar dinle; cevap sözlerde.',
    'Kırık ya da eskimiş bir şeyi bugün onar; talih tamir sever.',
    'Bugün cüzdanını düzenle; para düzen gördüğü yere yerleşir.',
    'Bir fincanı bugün yavaş iç; acele edilmeyen keyif bereket çağırır.',
    'Bugün az konuş, çok dinle; kulağına değecek bir cümle kıymetli.',
    'Yürüdüğün yolda bugün bir kez geri dön ve baktığın yere gülümse.',
    'Bugün masanın bir köşesini boşalt; boşluk yeni gelene yer açar.',
    'Sevdiğin bir kokuyu bugün üstüne sür; güzel koku güzel haber çeker.',
    'Bugün küçük bir söz ver ve tut; tutulan söz talihin tohumudur.',
    'Elini bugün toprağa ya da bir yaprağa değdir; köklenmek iyi gelir.',
    'Bugün erken yat; yarının şansı dinlenmiş gözlerle daha iyi görünür.',
    'Bir listeye bugün üç şükür maddesi yaz; şükür bolluğun anahtarıdır.',
  ];

  /// Günün şans renkleri (ad + tam opak ARGB).
  static const List<SansRengi> sansRenkleri = <SansRengi>[
    SansRengi(ad: 'Gece Mavisi', hexArgb: 0xFF1B2A4A),
    SansRengi(ad: 'Altın Sarısı', hexArgb: 0xFFF4C95D),
    SansRengi(ad: 'Nar Kırmızısı', hexArgb: 0xFFB23A48),
    SansRengi(ad: 'Zümrüt Yeşili', hexArgb: 0xFF2E8B57),
    SansRengi(ad: 'Lavanta Moru', hexArgb: 0xFF8B7EC8),
    SansRengi(ad: 'Gül Kurusu', hexArgb: 0xFFC08081),
    SansRengi(ad: 'Turkuaz', hexArgb: 0xFF30B8B2),
    SansRengi(ad: 'Kehribar', hexArgb: 0xFFDC9A3E),
    SansRengi(ad: 'Fildişi', hexArgb: 0xFFF5EFE0),
    SansRengi(ad: 'Bakır', hexArgb: 0xFFB0653A),
    SansRengi(ad: 'Orman Yeşili', hexArgb: 0xFF1F5C40),
    SansRengi(ad: 'Lila', hexArgb: 0xFFB79FD4),
    SansRengi(ad: 'Mercan', hexArgb: 0xFFE9705F),
    SansRengi(ad: 'Duman Grisi', hexArgb: 0xFF8C93A0),
    SansRengi(ad: 'Safir', hexArgb: 0xFF2456A6),
    SansRengi(ad: 'Ay Işığı', hexArgb: 0xFFE8E3D3),
  ];
}
