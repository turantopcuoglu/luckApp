# K7 kanıtı: tanışma cevabı kodunun kaldırılması

Karar: `STUDIO/KARARLAR.md`, 2026-11-26 satırı (2): "tanışma soruları kalkar (K7)". Turan'ın sözü: "Tanışma soruları olmasın bence… çok ucuz falcı gibi oluyoruz." Soruların ekranı 11 Kasım'da kalkmıştı. Bu adımda yalnızca arkada kalan kod temizlendi: `OkuyucuTercihleri`, `IliskiDurumu`, `Ugras`, uğraş ve ilişki sahneleri, "kişisel Yap" havuzu ve profil ekleri.

## Adım 1 (yapı temizliği): üretim çıktısı değişmedi

| Ölçüm | Sonuç |
|---|---|
| Döküm: 16 kişi × tam ad var/yok × 3 harita durumu × 75 gün; her anahtarda günlük, 5 kategori ve 15 günde bir profil | 43 680 anahtar, eski ve yeni dosya bayt bayt aynı (`cmp`). SHA-256 `dokum_sha256.txt` içinde |
| Döküm testi | `dokum_testi.dart.txt`: geçici test, repoda tutulmadı |
| Altın kayıt (207 anahtar) | 123 anahtar aynı. Bunların arasında bütün t0 anahtarları (48, Türkiye) ve uyum var |
| Değişen altın anahtarlar (84) | gunluk/kategori/profil t1 ve t2 (24'er) ile begeni (12). Bu durumlar eskiden **tercih seti olan test okuyucularıydı**; üretimde öyle bir okuyucu yok. Artık üretimde var olan durumlar ölçülüyor: tam ad, tam ad + Ay burcu + yükselen. Ayrıntı: `altin_once.txt` ↔ `altin_sonra.txt` |
| `flutter analyze` | No issues found |
| `flutter test` (TZ=Europe/Istanbul) | 498 test geçti. Önceki sayı 502'ydi: tercihlere özel 19 test kalktı, portre ve "ilişki varsaymaz" için 15 test geldi |

## İçerik açıkları (karar Turan'da, kod düzeltmesi okumayı değiştirir)

1. **Aşk tarzı havuzları küçüldü.** İlişki durumu varsayan 7 cümle `karakter_yonleri.dart`'tan silindi. Üretimde zaten hiç gösterilmiyorlardı: çelişki kapısı ikisini de her zaman eliyordu, döküm bu yüzden aynı çıktı. Yaşam yolu başına kalan aşk cümlesi: 1:4, 2:4, 3:3, 4:4, 5:3, 6:3, 7:4, 8:3, 9:4, 11:3, 22:2, 33:4. Diğer kategorilerin sınırı 4. Aşk için sınır geçici olarak `ContentConfig.enAzAskTarzVaryanti` (= 2). Bu sayının altına düşen havuzda o gün burç cümlesi kullanılır; bu davranış eskiden de vardı. Öneri: her yaşam yoluna ilişki varsaymayan 1-2 aşk cümlesi eklemek.
2. **Tekrar aşımı (eskiden de vardı).** Yaşam yolu 9 için 2026-10-01'den başlayan 30 günde şu cümle 7 kez geliyor (sınır 6): "Oğlak burcu olarak ilk izlenimde mesafeli görünebilirsin; seni tanıyanlar ise sıcaklığını bilir." Aynı test eski `lib` koduyla çalıştırıldı ve aynı aşımı verdi. Eski test okuyucusu cevap setiyle bu cümleyi gizliyordu. `tekrar_denetimi_test.dart` içinde açık bir "bilinen aşım" kaydı olarak duruyor; yeni bir aşım kabul etmez.
