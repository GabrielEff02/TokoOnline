import '../core/app_export.dart';

class CustomTextStyle {
  static get headlineSmallBlueA700 => theme.textTheme.headlineSmall!
      .copyWith(color: appTheme.blueA700, fontWeight: FontWeight.w700);

  static get lableLargeBlack900 =>
      theme.textTheme.labelLarge!.copyWith(color: appTheme.black900);
  static get lableLargeBlack900500 => theme.textTheme.labelLarge!
      .copyWith(color: appTheme.black900, fontWeight: FontWeight.w500);
  static get lableLargeGreen700500 => theme.textTheme.labelLarge!
      .copyWith(color: appTheme.green700, fontWeight: FontWeight.w500);
  static get lableLargeBluegray300 =>
      theme.textTheme.labelLarge!.copyWith(color: appTheme.blueGray300);
  static get lableLargeRed700 =>
      theme.textTheme.labelLarge!.copyWith(color: appTheme.red700);

  static get titleLargeBlack900 => theme.textTheme.titleLarge!
      .copyWith(color: appTheme.black900, fontWeight: FontWeight.w700);

  static get titleMediumBlack900 => theme.textTheme.titleMedium!
      .copyWith(color: appTheme.black900, fontWeight: FontWeight.w700);
  static get titleMediumRed700 => theme.textTheme.titleMedium!
      .copyWith(color: appTheme.red700, fontWeight: FontWeight.w700);
  static get titleMediumGreen700 => theme.textTheme.titleMedium!
      .copyWith(color: appTheme.green700, fontWeight: FontWeight.w700);
  static get titleMediumBlueA700 =>
      theme.textTheme.titleMedium!.copyWith(color: appTheme.blueA700);
  static get titleMediumBlueA70016 => theme.textTheme.titleMedium!
      .copyWith(color: appTheme.blueA700, fontSize: 16.fSize);
  static get titleMediumBluegray400 => theme.textTheme.titleMedium!.copyWith(
      color: appTheme.blueGray400,
      fontSize: 16.fSize,
      fontWeight: FontWeight.w500);
  static get titleMediumBluegray900 =>
      theme.textTheme.titleMedium!.copyWith(color: appTheme.blueGray900);
  static get titleMediumBlueGray900Medium =>
      theme.textTheme.titleMedium!.copyWith(
          color: appTheme.blueGray900,
          fontSize: 16.fSize,
          fontWeight: FontWeight.w500);
  static get titleMediumBold =>
      theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700);
  static get titleMediumGray90001 => theme.textTheme.titleMedium!.copyWith(
      color: appTheme.gray90001,
      fontSize: 16.fSize,
      fontWeight: FontWeight.w500);
  static get titleMediumGray90002 => theme.textTheme.titleMedium!
      .copyWith(color: appTheme.gray90002, fontSize: 16.fSize);
  static get titleMediumWhiteA700 =>
      theme.textTheme.titleMedium!.copyWith(color: appTheme.whiteA700);

  static get titleSmallGreen700 => theme.textTheme.titleSmall!
      .copyWith(color: appTheme.green700, fontWeight: FontWeight.w700);
  static get titleSmallBlack900 => theme.textTheme.titleSmall!
      .copyWith(color: appTheme.black900, fontWeight: FontWeight.bold);
  static get titleSmallBluegray400 =>
      theme.textTheme.titleSmall!.copyWith(color: appTheme.blueGray400);
  static get titleSmallBluegray900 => theme.textTheme.titleSmall!
      .copyWith(color: appTheme.blueGray900, fontWeight: FontWeight.bold);
  static get titleSmallWhiteA700 =>
      theme.textTheme.titleSmall!.copyWith(color: appTheme.whiteA700);
  static get titleSmallWhiteA700Bold => theme.textTheme.titleSmall!
      .copyWith(color: appTheme.whiteA700, fontWeight: FontWeight.w700);

  // Add missing getters
  static get titleMediumBlueGray800 =>
      theme.textTheme.titleMedium!.copyWith(color: appTheme.blueGray800);

  static get titleSmallBlueGray800 =>
      theme.textTheme.titleSmall!.copyWith(color: appTheme.blueGray800);

  static get bodySmallBlueGray600 =>
      theme.textTheme.bodySmall!.copyWith(color: appTheme.blueGray600);

  static get bodyMediumBlueGray600 =>
      theme.textTheme.bodyMedium!.copyWith(color: appTheme.blueGray600);
  static get bodyMediumGreen700 =>
      theme.textTheme.bodyMedium!.copyWith(color: appTheme.green700);
  static get bodyMediumRed700 =>
      theme.textTheme.bodyMedium!.copyWith(color: appTheme.red700);
  static get bodySmallBlack900 =>
      theme.textTheme.bodySmall!.copyWith(color: appTheme.black900);

  static get bodyLargeGreen700 =>
      theme.textTheme.bodyLarge!.copyWith(color: appTheme.green700);
  static get bodyLargeRed700 =>
      theme.textTheme.bodyLarge!.copyWith(color: appTheme.red700);
}
