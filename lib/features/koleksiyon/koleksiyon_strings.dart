/// Koleksiyon özelliğinin Türkçe metinleri.
abstract final class KoleksiyonStrings {
  /// Ekran başlığı.
  static const String baslik = 'Koleksiyon';

  /// "5 / 24 kart" sayacı.
  static String sayac(int kazanilan, int toplam) => '$kazanilan / $toplam kart';

  /// Kartın kaç farklı günde geldiği.
  static String gunSayisi(int gun) =>
      gun == 1 ? 'İlk kez katıldın.' : '$gun farklı günde katıldın.';

  /// İlk kazanılma tarihi satırı.
  static String ilkGun(String tarih) => 'İlk kez $tarih tarihinde geldi.';

  /// Nadir rozeti.
  static const String nadir = 'Nadir';

  /// Henüz kazanılmamış kartın açıklaması.
  static const String kilitliAciklama =
      'Bu kart henüz gelmedi. Her gün kartını açtığında koleksiyonuna bir '
      'kart katılır.';

  /// Koleksiyon boşken gösterilen davet.
  static const String bosDurum =
      'Henüz kartın yok. Bugün kartını açtığında ilk kartın gelecek.';

  /// Ana ekrandaki panelin üst etiketi.
  static const String bugununKarti = 'BUGÜNÜN KARTI';

  /// Kart koleksiyona girdi.
  static const String eklendi = 'Koleksiyonuna eklendi';

  /// Kart nadir olarak geldi.
  static const String nadirEklendi = 'Nadir! Koleksiyonuna eklendi';

  /// Profil özet kartının açıklaması.
  static const String ozetAciklama =
      'Her gün açtığın kart burada birikir. Nadir kartlar altın çerçeveyle '
      'gelir.';

  /// Koleksiyon ekranının alt notu.
  static const String altNot =
      'Kartlar eğlence amaçlıdır; günün skorunu ya da okumasını etkilemez.';

  /// Kart adları ve kısa sözleri (katalog kimliği → (ad, söz)).
  static const Map<String, (String, String)> kartlar =
      <String, (String, String)>{
        'hilal_kemer': (
          'Hilal Kemeri',
          'Kemerin ardındaki ince ışık, yolunu sessizce aydınlatır.',
        ),
        'isik_kapisi': (
          'Işık Kapısı',
          'Açılan her kapı, yeni bir başlangıca verilen küçük bir evettir.',
        ),
        'mor_gece': (
          'Mor Gece',
          'Yavaşlamak da ilerlemektir; gece, dinlenen her şeyi besler.',
        ),
        'acik_kapi': (
          'Açık Kapı',
          'Kapı aralık; içeri girmek için tek bir adım yeter.',
        ),
        'hilal_yildiz': (
          'Hilal ve Yıldız',
          'Küçük bir ışık, karanlığın bütün havasını değiştirir.',
        ),
        'kopruler': ('Kesişen Yollar', 'Farklı yollar bazen aynı göle varır.'),
        'cam_fanus': (
          'Sessiz Tohum',
          'Büyüme sessizdir; görünmeden önce kök salar.',
        ),
        'kagit_ucak': (
          'Uçan Not',
          'Bir düşünceyi yazmak, onu yola çıkarmaktır.',
        ),
        'tas_kule': (
          'Dengeli Taş',
          'Denge, her taşı yerine sabırla koymaktır.',
        ),
        'dag_yolu': ('Yeni Patika', 'Dağa giden yol, ilk adımla başlar.'),
        'sonsuzluk': (
          'Geri Dönen Şerit',
          'Bazı anlar döner; her dönüşte biraz daha parlar.',
        ),
        'tas_kopru': (
          'Küçük Köprü',
          'İki kıyıyı birleştirmek için büyük olmak gerekmez.',
        ),
        'dolunay': ('Dolunay', 'Tamamlanan her döngü, yeni bir ışık getirir.'),
        'teras': ('Sessiz Teras', 'Durup nefes almak da yolun bir parçasıdır.'),
        'isik_yolu': (
          'Işık Yolu',
          'Suyun üstündeki ışık, her adımda biraz daha uzar.',
        ),
        'yildiz_yolu': (
          'Yıldız Yolu',
          'Uzak görünen yıldız, yolun yönünü gösterir.',
        ),
        'acik_pencere': (
          'Açık Pencere',
          'Açılan pencereden ışıkla birlikte yeni bir fikir de girer.',
        ),
        'yuzen_fener': (
          'Yüzen Fener',
          'Tek bir fener bile göle kendi yolunu çizer.',
        ),
        'kum_saati': ('Kum Saati', 'Zaman akar; her tanesi bir yıldız tozu.'),
        'altin_tuy': (
          'Altın Tüy',
          'Hafiflik de bir güçtür; bırakınca süzülürsün.',
        ),
        'cam_merdiven': (
          'Cam Merdiven',
          'Her basamak, bir öncekinin üstüne kurulur.',
        ),
        'yildiz_cesmesi': (
          'Yıldız Çeşmesi',
          'Paylaştıkça çoğalan ışık gibi bir gün.',
        ),
        'ay_salincagi': (
          'Ay Salıncağı',
          'Biraz oyun, ruhun en sevdiği moladır.',
        ),
        'pusula': (
          'Pusula',
          'Yön bulmak için önce durup içine bakmak gerekir.',
        ),
      };
}
