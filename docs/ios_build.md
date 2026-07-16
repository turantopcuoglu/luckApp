# iPhone'a Kurulum — macOS'ta iOS Derleme Rehberi (Turan)

Depoyu Mac'e klonlayıp doğrudan Xcode'da açmak ÇALIŞMAZ: Flutter'ın
makine-yerel üretim adımları (pub get + CocoaPods) her Mac'te bir kez
koşmalıdır. Bu rehber sık görülen üç hatayı ve tam kurulum sırasını verir.
(Widget'ın iOS tarafı için ayrıca bkz. `ios_widget_setup.md`.)

## Hata → Neden → Çözüm

| Hata | Neden | Çözüm |
|---|---|---|
| `could not find included file 'Generated.xcconfig'` | Dosya gitignore'ludur; her makinede `flutter pub get` üretir. Mac'te hiç çalışmamış. | Adım 2 |
| `Module 'flutter_local_notifications' not found` | Native eklentiler CocoaPods ile gelir; `pod install` hiç koşmamış. | Adım 3 |
| `#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"` bulunamadı | Aynı neden: `Pods/` dizini yok. Ayrıca muhtemelen `Runner.xcodeproj` açılmış. | Adım 3 + 4 |
| `pod install` başarılı olduğu hâlde `Module ... not found` sürüyor; pod install "CocoaPods did not set the base configuration" uyarısı veriyor | `ios/Flutter/Debug.xcconfig`/`Release.xcconfig` dosyalarında Pods include satırları eksikti — pod'lar kuruluyor ama derlemeye girmiyordu. | Depoda düzeltildi: `git pull` → Xcode'da Product → Clean Build Folder (⇧⌘K) → yeniden derle |

## Kurulum Sırası

### 1. Önkoşullar (bir kez)
```bash
# Xcode App Store'dan kurulu olmalı, sonra:
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept

# Flutter SDK kurulu ve yolda olmalı:
flutter doctor        # iOS satırı yeşil olana kadar önerilerini uygula

# CocoaPods:
brew install cocoapods   # (ya da: sudo gem install cocoapods)
```

### 2. Flutter üretim dosyaları (Generated.xcconfig buradan gelir)
```bash
cd luckApp
flutter clean
flutter pub get
```

### 3. Podları kur (eklenti modülleri buradan gelir)
```bash
# Depoda Podfile yoktur; Flutter ilk derlemede otomatik üretir:
flutter build ios --config-only

cd ios
pod install            # ağ hatası verirse: pod repo update && pod install
cd ..
```

### 4. Xcode'u DOĞRU dosyayla aç
```bash
open ios/Runner.xcworkspace
```
**ASLA `Runner.xcodeproj` açma** — pods kullanan projede modüller yalnız
workspace üzerinden görünür.

### 5. İmzalama (ücretsiz Apple ID yeterli)
- Xcode → Runner target → **Signing & Capabilities**
- **Team**: kişisel Apple ID'ni ekle/seç
- Bundle Identifier çakışma hatası verirse benzersiz yap
  (örn. `com.turan.kader1990`).
- Not: Bundle id değişirse widget kurulumundaki App Group kimliği
  (`group.com.turan.kader`) de buna uyumlu güncellenmeli
  (bkz. `ios_widget_setup.md`).

### 6. Telefona kur
```bash
# iPhone'u kabloyla bağla, telefonda "Trust This Computer" onayla, sonra:
flutter devices        # cihaz kimliğini gör
flutter run -d <cihaz-kimliği>   # ya da Xcode'da ▶
```
İlk açılışta iPhone'da: **Settings → General → VPN & Device Management →**
geliştirici profiline güven.

## Sık Tuzaklar
- **7 gün kuralı:** Ücretsiz hesapla imzalanan uygulama 7 gün sonra
  açılmaz olur; Xcode/`flutter run` ile yeniden kurmak yeter.
- **`pod install` ağ hatası:** `pod repo update` sonra tekrar dene.
- **Temiz başlangıç:** Tuhaf derleme hatalarında sırayla:
  `flutter clean && flutter pub get && cd ios && pod install`.
- **Podfile commit'lenmez:** Flutter'ın ürettiği Podfile makinedeki
  Flutter sürümüyle uyumludur; depoya elle sabitlemek sürüm kaymasında
  kırılganlık yaratır. `Pods/` zaten gitignore'ludur.
