import '../core/app_export.dart';

class AppDecoration {
  static BoxDecoration get fillBlue => BoxDecoration(color: appTheme.blue50);
  static BoxDecoration get fillBlueA => BoxDecoration(color: appTheme.blue50);
  static BoxDecoration get fillGray => BoxDecoration(color: appTheme.gray50);
  static BoxDecoration get fillRed => BoxDecoration(color: appTheme.red700);

  static BoxDecoration get fillWhiteA =>
      BoxDecoration(color: appTheme.whiteA700);

  static BoxDecoration get outlineGray =>
      BoxDecoration(color: appTheme.whiteA700, boxShadow: [
        BoxShadow(
            color: appTheme.gray70011.withOpacity(0.15),
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              0,
            ))
      ]);

  static BoxDecoration get outlineGray60026 =>
      BoxDecoration(color: appTheme.whiteA700, boxShadow: [
        BoxShadow(
            color: appTheme.gray60026,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              2.41,
            ))
      ]);

  static BoxDecoration get outlineGray70011 =>
      BoxDecoration(color: appTheme.whiteA700, boxShadow: [
        BoxShadow(
            color: appTheme.gray70011,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              0,
            ))
      ]);
}

class BorderRadiusStyle {
  static BorderRadius get roundedBorder3 => BorderRadius.circular(3.h);
  static BorderRadius get roundedBorder6 => BorderRadius.circular(6.h);
}
