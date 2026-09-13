/// Bildirim ve dil alanları eklenmeden önce kaydedilmiş profil map'i.
///
/// Bu fixture migration testlerinde değiştirilmeden kullanılmalıdır; yeni
/// alanlar eklenirse eski kaydın varsayılanlarla açılabildiğini kanıtlar.
const Map<String, dynamic> legacyUserProfileFixture = <String, dynamic>{
  'isim': 'Turan',
  'dogumTarihi': '1990-05-15T00:00:00.000',
  'onboardingTamam': true,
};

/// Feedback alanları eklenmeden önce kaydedilmiş günlük sonuç map'i.
///
/// Enum adları Hive sözleşmesinin parçasıdır; bu fixture adların veya iç içe
/// map yapısının yanlışlıkla değiştirilmesini yakalar.
const Map<String, dynamic> legacyDailyRecordFixture = <String, dynamic>{
  'sonuc': <String, dynamic>{
    'gun': '2026-07-06T00:00:00.000',
    'genelSkor': 62,
    'kategoriler': <String, int>{
      'ask': 78,
      'para': 53,
      'saglik': 75,
      'risk': 49,
      'sosyal': 46,
    },
    'modifiyerler': <Map<String, dynamic>>[
      <String, dynamic>{'ad': 'Ay evresi', 'etki': 2},
      <String, dynamic>{'ad': 'Gün numerolojisi', 'etki': -1},
    ],
  },
};
