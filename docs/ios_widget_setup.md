# iOS Ana Ekran Widget'ı — Kurulum (Turan)

Android widget'ı kod tarafında tamamen hazırdır ve otomatik çalışır. iOS
WidgetKit ise Xcode'da bir **Widget Extension target'ı** ve **App Group**
gerektirir; bunlar cihaz/Xcode işi olduğundan elle bir kez kurulur. Aşağıdaki
adımlar tek seferliktir.

Flutter tarafı hazır: `HomeWidgetService` veriyi App Group'a yazıp widget'ı
yeniler; anahtarlar (`skor`, `tarih`, `teaser`) ve App Group kimliği
`group.com.turan.kader` Dart'ta `lib/features/home_widget/widget_config.dart`
içinde tanımlıdır.

## Adımlar

1. **Widget Extension target ekle**
   - Xcode → `ios/Runner.xcworkspace` aç.
   - File → New → Target → **Widget Extension**.
   - Product Name: `KaderWidget`. "Include Configuration Intent" **işaretsiz**.
   - Dili Swift bırak, Finish. (Activate scheme sorarsa Activate.)

2. **Hazır Swift kaynağını kullan**
   - Xcode'un oluşturduğu `KaderWidget.swift` yerine bu repodaki
     `ios/KaderWidget/KaderWidget.swift` içeriğini kullan (kopyala/değiştir).
   - Dosyanın **Target Membership**'i `KaderWidgetExtension` olmalı.

3. **App Group tanımla (paylaşımlı veri için)**
   - Signing & Capabilities'te **hem `Runner` hem `KaderWidgetExtension`**
     target'ına **App Groups** capability'si ekle.
   - Her ikisinde de aynı grubu seç/oluştur: **`group.com.turan.kader`**.
   - Bu kimlik Dart `WidgetConfig.appGroupId` ile birebir aynı olmalı.

4. **Deployment target**
   - `KaderWidgetExtension` iOS Deployment Target'ını Runner ile uyumlu
     (≥ 14.0) yap.

5. **Çalıştır ve doğrula**
   - Uygulamayı bir kez aç (veri App Group'a yazılır).
   - Ana ekrana widget'ı ekle (uzun bas → + → Kader) → skor + tarih görünür.
   - Uygulamayı her açtığında güncellenir.

## Notlar

- **Anahtarlar sabit:** `skor`, `tarih`, `teaser` — değiştirirsen hem Dart
  `WidgetConfig` hem Swift dosyasını birlikte güncelle.
- **Gece yarısı yenilenme:** Bu MVP'de veri uygulama açılışında yazılır;
  widget en son açtığın günün skorunu + tarihini gösterir. Arka planda
  gece yarısı otomatik yeniden hesaplama gelecekteki bir geliştirmedir
  (Dart headless isolate + `home_widget` background callback).
