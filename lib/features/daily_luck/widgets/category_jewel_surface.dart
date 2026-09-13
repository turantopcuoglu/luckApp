import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/luck_engine/luck_category.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/cosmic_config.dart';

/// Pastel renk örtüsü yerine doygun taş/cam malzemesinin üç ışık rengi.
class CategoryJewelPalette {
  const CategoryJewelPalette._(this.accent, this.body, this.glow);

  /// İkon, sayı ve ince kenar; koyu yüzeyde okunaklıdır.
  final Color accent;

  /// Doygun fakat metinle yarışmayan temel taş rengi.
  final Color body;

  /// Alttan gelen renkli yansıma.
  final Color glow;

  /// Yalnız kategori kimliği; skor, kilitli değer veya nadirlik kullanılmaz.
  static CategoryJewelPalette of(LuckCategory category) => switch (category) {
    LuckCategory.ask => const CategoryJewelPalette._(
      Color(0xFFFF91C2),
      Color(0xFF432036),
      Color(0xFFCA367D),
    ),
    LuckCategory.para => const CategoryJewelPalette._(
      Color(0xFFFFD677),
      Color(0xFF3D3019),
      Color(0xFFBC821D),
    ),
    LuckCategory.saglik => const CategoryJewelPalette._(
      Color(0xFF87F2C0),
      Color(0xFF103E32),
      Color(0xFF0BA97C),
    ),
    LuckCategory.sosyal => const CategoryJewelPalette._(
      Color(0xFF6FDEFF),
      Color(0xFF0D354F),
      Color(0xFF008EC7),
    ),
    LuckCategory.risk => const CategoryJewelPalette._(
      Color(0xFFFFBE86),
      Color(0xFF492C20),
      Color(0xFFD7782D),
    ),
  };
}

/// Küçük kutular için sabit, skor bilgisinden bağımsız çizim bütçesi.
abstract final class CategoryJewelConfig {
  /// Her kutunun sabit ince gren noktası sayısı.
  static const int grainCount = 180;

  /// Mat yüzeyin içindeki ince mineral damarları.
  static const int veinCount = 3;

  /// Okunabilir tabanın içindeki renk doygunluğu; beyaz örtü kullanılmaz.
  static const double coreTint = .30;

  /// Gren, yazı ve sayının kontrastını düşürmez.
  static const double grainOpacity = .10;

  /// Kutuyu çevreleyen ışık düşük maliyetli, statik bir vurgudur.
  static const double glowRadius = 9;

  /// Damar çizgisinin mantıksal kalınlığı.
  static const double veinWidth = .55;
}

/// Renkli cam derinliği, ince doku, parlak kenar; etkileşim gerçek InkWell'dir.
class CategoryJewelSurface extends StatelessWidget {
  /// Kapalı durumda daha sakin dokulu yüzey; sayıya bakılarak stil seçilmez.
  const CategoryJewelSurface({
    required this.category,
    required this.revealed,
    required this.child,
    this.onTap,
    super.key,
  });

  /// Kategori malzemesi.
  final LuckCategory category;

  /// Genel kart açıldı mı; premium skoru veya kilit durumunu taşımaz.
  final bool revealed;

  /// Gerçek etiket ve yalnız yetkili skor/kilit.
  final Widget child;

  /// Kategori detayı ya da erişim ekranı.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final CategoryJewelPalette palette = CategoryJewelPalette.of(category);
    final BorderRadius radius = BorderRadius.circular(AppRadius.sm);
    final Color base = revealed ? palette.body : CosmicConfig.navigationSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          if (revealed)
            BoxShadow(
              color: palette.glow.withValues(alpha: .16),
              blurRadius: CategoryJewelConfig.glowRadius,
            ),
        ],
      ),
      child: Material(
        color: base,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: RadialGradient(
              center: const Alignment(.7, .95),
              radius: 1.35,
              colors: <Color>[
                revealed
                    ? Color.lerp(
                        base,
                        palette.glow,
                        CategoryJewelConfig.coreTint,
                      )!
                    : base,
                base,
                Color.lerp(base, CosmicConfig.navigationSurface, .55)!,
              ],
            ),
            border: Border.all(
              color: (revealed ? palette.accent : CosmicConfig.social)
                  .withValues(alpha: revealed ? .70 : .28),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: palette.accent.withValues(alpha: .16),
            focusColor: palette.accent.withValues(alpha: .18),
            child: CustomPaint(
              painter: CategoryJewelTexture(
                category: category,
                revealed: revealed,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bitmap yüklemeyen deterministik gren, cam yansıması ve mineral damarları.
class CategoryJewelTexture extends CustomPainter {
  /// Aynı malzeme girdisi aynı pikselleri üretir.
  const CategoryJewelTexture({required this.category, required this.revealed});

  /// Desenin tek tohumu; kilitli skor dahil hiçbir kullanıcı değeri kullanılmaz.
  final LuckCategory category;

  /// Açık ve kapalı kartta aynı desen, farklı ışık yoğunluğu.
  final bool revealed;
  @override
  void paint(Canvas canvas, Size size) {
    final CategoryJewelPalette palette = CategoryJewelPalette.of(category);
    final double strength = revealed ? 1 : .35;
    final Paint paint = Paint();
    // Yansıma üst kenarda kalır, metnin arkasına beyaz sis bırakmaz.
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        palette.accent.withValues(alpha: .13 * strength),
        Colors.transparent,
        Colors.transparent,
      ],
      stops: const <double>[0, .40, 1],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
    paint.shader = null;
    for (int i = 0; i < CategoryJewelConfig.grainCount; i++) {
      final double x =
          ((i * .61803398875 + category.index * .071) % 1) * size.width;
      final double y =
          ((i * .754877666 + category.index * .137) % 1) * size.height;
      paint.color = (i.isEven ? palette.accent : Colors.black).withValues(
        alpha: CategoryJewelConfig.grainOpacity * strength * (.4 + (i % 5) / 8),
      );
      canvas.drawCircle(Offset(x, y), i % 7 == 0 ? .65 : .32, paint);
    }
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = CategoryJewelConfig.veinWidth;
    for (int i = 0; i < CategoryJewelConfig.veinCount; i++) {
      final double drift = math.sin(category.index + i) * .06;
      final Path vein = Path()
        ..moveTo(size.width * (.1 + i * .35), size.height)
        ..cubicTo(
          size.width * (.8 + drift),
          size.height * .78,
          -size.width * .2,
          size.height * .46,
          size.width * (.3 + i * .38),
          0,
        );
      paint.color = palette.accent.withValues(alpha: .08 * strength);
      canvas.drawPath(vein, paint);
    }
    paint
      ..strokeWidth = .8
      ..color = palette.accent.withValues(alpha: .42 * strength);
    canvas.drawLine(
      const Offset(AppSpacing.sm, 1),
      Offset(size.width - AppSpacing.sm, 1),
      paint,
    );
  }

  @override
  bool shouldRepaint(CategoryJewelTexture oldDelegate) =>
      category != oldDelegate.category || revealed != oldDelegate.revealed;
}
