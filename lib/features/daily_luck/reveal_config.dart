/// Kartın deterministik, sabit bütçeli koreografi ve çizim ölçüleri.
abstract final class RevealConfig {
  /// Kapalı kart dokusunun yükseklik/genişlik oranı.
  static const double cardAspect = 1.5;

  /// Ayrılmış katmanların kaydetme sırasında koruduğu görünürlük.
  static const double layerFade = .8;

  /// Dikiş izinin çevre uzunluğuna oranı.
  static const double seamTail = .22;

  /// Folyo ışığının azami opaklığı.
  static const double foilOpacity = .18;

  /// Işık tozu, elmas, iz ve yıldız şekilleri.
  static const int particleKinds = 4;

  /// Referans: 250 ms mühür + 400 ms ışık + 650 ms açılış; sonra 700 ms yerleşme.
  static const Duration opening = Duration(milliseconds: 1300);

  /// Kapalı kartın sahne genişliğine oranı; açık sahnede aynı geometri korunur.
  static const double stageCardRatio = .64;

  /// Mühür/selection haptic anı.
  static const double sealAt = 80 / 1300;

  /// Mühür nabzının bitişi.
  static const double sealEnd = 250 / 1300;

  /// Folyo ve dikiş aralığı.
  static const double seamStart = 250 / 1300;

  /// 650 ms: ışık dikişinin sonu.
  static const double seamEnd = 650 / 1300;

  /// 650 ms: kanat hareketinin başlangıcı.
  static const double unfoldStart = 650 / 1300;

  /// Parçacıkların başlangıcı.
  static const double bloomStart = .50;

  /// Kartın 3B açı sınırı (radyan).
  static const double tilt = .075;

  /// Menteşenin son açılma açısı; hafif tilt'ten bağımsızdır.
  static const double hingeAngle = 1.1;

  /// Perspektif katsayısı.
  static const double perspective = .0015;

  /// Yarım katmanların yana ayrılma mesafesi.
  static const double travel = 18;

  /// Hareketli kanatların ışıklı açık kapı çizimine karışmaya başladığı ilerleme.
  static const double panelBlendStart = .45;

  /// Sonuç girişindeki dikey mesafe.
  static const double entryTravel = 0;

  /// Sabit parçacık sayısı; frame başına yeniden oluşturulmaz.
  static const int particleCount = 12;

  /// Parçacık yörüngesi başlangıcı.
  static const double particleRadius = 38;

  /// Parçacık yörüngesindeki ek mesafe.
  static const double particleTravel = 105;

  /// Parçacık şekil ölçeği.
  static const double particleSize = 5;

  /// Mührün kart dokusu üzerindeki göreli dikey konumu.
  static const double sealY = .48;

  /// Mühür ışık halkası yarıçapı.
  static const double sealRadius = 38;

  /// Mühür nabız genişlemesi.
  static const double sealPulse = 7;

  /// Işık dikişi kalınlığı.
  static const double seamWidth = 2;

  /// Efektin yatay çizim tamponu.
  static const double padding = 36;
}
