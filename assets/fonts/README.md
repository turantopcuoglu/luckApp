# Kader yerel yazı tipleri

Inter ve Playfair Display değişken fontları 5 Eylül 2026 tarihinde
Google Fonts'un resmi deposundan alındı. Dosyalar değiştirilmedi; uygulama
ve testler bu yerel TTF dosyalarını kullanır. Ağdan font indirilmez.

Kaynaklar:

- [Inter](https://github.com/google/fonts/tree/main/ofl/inter)
  — `Inter[opsz,wght].ttf` → `Inter-Variable.ttf`.
- [Playfair Display](https://github.com/google/fonts/tree/main/ofl/playfairdisplay)
  — `PlayfairDisplay[wght].ttf` → `PlayfairDisplay-Variable.ttf`.

Her aileye ait SIL Open Font License metni yanında değiştirilmeden saklanır,
uygulama bundle'ına eklenir ve `AppTypography.registerLicenses()` ile Material
lisans ekranına kaydedilir. Bu README bundle'a girmez.

SHA-256:

```text
Inter-Variable.ttf
29160A80FF49DDCAB2C97711247E08B1FAB27A484A329CE8B813D820DC559031

PlayfairDisplay-Variable.ttf
C40F2293766A503BC70CCE9E512EF844A4CCB7CBCDE792FE2EA31D191917D8D6
```

Yeni paket eklenmedi. Eski `google_fonts` bağımlılığının kaldırılması bu
fazın kapsamında değil; tema artık onu çağırmıyor.
