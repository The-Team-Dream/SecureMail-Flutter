/// SecureMail — Spacing & Sizing System
/// Based on an 4px base grid
class AppSpacing {
  AppSpacing._();

  // ── Base Grid (4px) ───────────────────────────────────────
  static const double x1  = 4.0;
  static const double x2  = 8.0;
  static const double x3  = 12.0;
  static const double x4  = 16.0;
  static const double x5  = 20.0;
  static const double x6  = 24.0;
  static const double x8  = 32.0;
  static const double x10 = 40.0;
  static const double x12 = 48.0;
  static const double x16 = 64.0;

  // ── Screen Padding ────────────────────────────────────────
  static const double screenHorizontal = 14.0;
  static const double screenVertical   = 16.0;

  // ── Card ──────────────────────────────────────────────────
  static const double cardPaddingH = 16.0;
  static const double cardPaddingV = 14.0;

  // ── Input Field ───────────────────────────────────────────
  static const double fieldPaddingH = 14.0;
  static const double fieldPaddingV = 13.0;

  // ── Sections ──────────────────────────────────────────────
  static const double sectionGap     = 24.0;
  static const double itemGap        = 16.0;
  static const double smallGap       = 8.0;
}

/// SecureMail — Border Radius System
class AppRadius {
  AppRadius._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 10.0;
  static const double lg   = 12.0;
  static const double xl   = 16.0;
  static const double xxl  = 24.0;
  static const double full = 999.0; // pill shape
}

/// SecureMail — Icon Sizes
class AppIconSize {
  AppIconSize._();

  static const double xs  = 14.0;
  static const double sm  = 16.0;
  static const double md  = 20.0;
  static const double lg  = 24.0;
  static const double xl  = 28.0;
  static const double xxl = 32.0;
}

/// SecureMail — Component Heights
class AppSize {
  AppSize._();

  // Buttons
  static const double buttonHeightL = 48.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightS = 36.0;

  // Input Fields
  static const double fieldHeight = 48.0;

  // AppBar
  static const double appBarHeight = 56.0;

  // Bottom Nav Bar
  static const double bottomNavHeight = 64.0;

  // Avatar
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 48.0;
}