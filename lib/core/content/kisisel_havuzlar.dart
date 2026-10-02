import '../luck_engine/luck_engine.dart';
import 'okuyucu.dart';

/// Okuyucunun tercihlerine ve günün en zayıf kategorisine göre seçilen
/// ek metin havuzları.
///
/// Yazım rehberi için bkz. `sayi_metinleri.dart`. Yer tutucular:
/// `{saat}`, `{ugrasAlani}`, `{isim}`.
abstract final class KisiselHavuzlar {
  /// Kategoriye özel somut eylem önerisi (şanslı saatle).
  static const Map<LuckCategory, List<String>>
  eylemCumleleri = <LuckCategory, List<String>>{
    LuckCategory.ask: <String>[
      'Kalbinden geçen o mesajı {saat} arasında gönder.',
      'Sevdiğin biriyle küçük bir anı paylaşmak için {saat} aralığı en tatlı zaman.',
      '{saat} arasında birine içten bir iltifat et; yankısı akşama kadar sürer.',
      'Duygusal bir konuşmayı açacaksan {saat} arasını seç.',
    ],
    LuckCategory.para: <String>[
      'Ertelediğin hesabı, faturayı ya da teklif cevabını {saat} arasında ele al.',
      '{saat} arasında {ugrasAlani} için tek bir önceliği netleştir.',
      'Maddi bir konuşma yapacaksan {saat} aralığı sana daha çok netlik veriyor.',
      '{saat} arasında küçük bir bütçe kontrolü yap; sürpriz bir tasarruf çıkabilir.',
    ],
    LuckCategory.saglik: <String>[
      '{saat} arasında kısa bir yürüyüşe ya da esnemeye yer aç.',
      'Gün içindeki ilk gerçek molanı {saat} arasına koy.',
      '{saat} arasında ekranı bırakıp birkaç derin nefes al.',
      'Bedeninin istediği küçük bir iyiliği {saat} arasında yap: su, hava, sessizlik.',
    ],
    LuckCategory.risk: <String>[
      'Bir karar vereceksen {saat} arasında önce artılarını ve eksilerini yaz.',
      '{saat} arasında yeni bir şey dene ama sınırını önceden belirle.',
      'Cesur bir adımı {saat} aralığına sakla; o saatte zihnin daha berrak.',
      '{saat} arasında bir fırsatı değerlendirirken ikinci bir görüş al.',
    ],
    LuckCategory.sosyal: <String>[
      'Uzun zamandır konuşmadığın birine {saat} arasında bir selam gönder.',
      '{saat} arasında bir davete evet de ya da sen bir davet kur.',
      'Bir tanışma ya da buluşma planlıyorsan {saat} aralığı sana gülümsüyor.',
      '{saat} arasında birine yardım teklif et; bağınız güçlenecek.',
    ],
  };

  /// En zayıf kategori bile yüksekse kullanılan "gölgesiz gün" notları.
  static const List<String> golgesizGun = <String>[
    'Bugün belirgin bir zayıf alan görünmüyor; tek dikkat noktası, iyi giden bir şeyi fazla zorlamamak.',
    'Bugün hayatının hiçbir alanında belirgin bir engel yok; yine de enerjini tek bir hedefe toplamak daha çok kazandırır.',
    'Bugün işlerin genel olarak yolunda; bu rahatlığı sevdiğin birkaç kişiyle paylaşmak günü daha da güzelleştirir.',
    'Bugün dikkat edilecek tek şey: fırsatların çokluğunda seçici kalmak.',
  ];

  /// Enerji tarzına göre günün tavsiyesine karışan kişisel tavsiyeler.
  static const Map<EnerjiTarzi, List<String>>
  enerjiTavsiyeleri = <EnerjiTarzi, List<String>>{
    EnerjiTarzi.iceDonuk: <String>[
      'Bugün kendine en az yarım saatlik sessiz bir alan ayır; şarjın orada doluyor.',
      'Kalabalık bir plan varsa sonrasına sakin bir akşam koy.',
      'Bugün bir fikri konuşmadan önce yazıya dök; seni daha iyi anlatır.',
      'Telefonu bir süre sessize al; iç sesin daha net duyulacak.',
      'Bugün tek bir yakın dostla derin bir sohbet, on yüzeysel sohbetten değerli.',
      'Yalnız bir yürüyüş bugün zihnindeki düğümü çözebilir.',
    ],
    EnerjiTarzi.disaDonuk: <String>[
      'Bugün birini ara ya da bir kahveye çağır; enerjin insanlarla yükseliyor.',
      'Bir fikrini bugün yüksek sesle paylaş; tepkiler onu geliştirecek.',
      'Bugün yeni bir ortama adım at; tanışacağın biri sana ilham verebilir.',
      'Ekip halinde yapılan bir iş bugün sana tek başına yapılandan daha çok keyif verir.',
      'Bugün birine moral vermek, senin de moralini yükseltir.',
      'Akşam için küçük bir buluşma planla; günün yorgunluğunu alır.',
    ],
  };

  /// Uğraş bilinmediğinde `{ugrasAlani}` yerine geçen ad öbeği.
  static const String varsayilanUgrasAlani = 'günlük işlerin';

  /// Profil "Aşkta" bölümüne ilişki durumuna göre eklenen cümle
  /// (false: bekar, true: partnerli).
  static const Map<bool, String> profilIliskiEki = <bool, String>{
    false:
        'Şu an yalnız yürüyorsan bu dönem, kimi aradığını değil kim '
        'olduğunu netleştirmek için değerli; doğru kişi en çok kendine '
        'benzediğin anlarda fark eder seni.',
    true:
        'Bir ilişkinin içindeysen, bu özelliklerin partnerinle kurduğun '
        'günlük ritimde görünür; ona ne zaman alan, ne zaman yakınlık '
        'gerektiğini söylemek bağınızı güçlendirir.',
  };

  /// Profil "İşte ve parada" bölümüne uğraşa göre eklenen cümle.
  static const Map<Ugras, String> profilUgrasEki = <Ugras, String>{
    Ugras.calisiyor:
        'Bugünkü işinde bu yanını görünür kılmak — bir '
        'toplantıda sözü almak ya da bir süreci sahiplenmek — değerini '
        'daha hızlı fark ettirir.',
    Ugras.ogrenci:
        'Öğrencilik döneminde bu eğilimlerin, hangi derslerde '
        'zamanın nasıl geçtiğini unuttuğuna bakınca kendini gösterir; '
        'o dersler sana ileride bir yön fısıldıyor olabilir.',
    Ugras.isArayan:
        'İş ararken bu güçlü yanlarını özgeçmişinde ve '
        'görüşmelerde somut bir örnekle anlatmak, seni kalabalıktan ayırır.',
    Ugras.girisimci:
        'Kendi işinde bu yanın hem motorun hem de kör '
        'noktan olabilir; güçlü olduğun alanı büyütürken zayıf kaldığın '
        'yeri güvendiğin biriyle paylaşmak işini hızlandırır.',
    Ugras.evde:
        'Ev ve aile düzenini yönetmek de gerçek bir iştir; bu '
        'yeteneklerin orada her gün sessizce çalışıyor ve istersen yeni '
        'bir üretime de dönüşebilir.',
  };
}
