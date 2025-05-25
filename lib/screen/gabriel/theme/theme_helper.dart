import '../core/app_export.dart';

String _appTheme = "lightCode";
LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

class ThemeHelper {
  // ignore: prefer_final_fields
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };
  // ignore: prefer_final_fields
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  void changeTheme(String newTheme) {
    _appTheme = newTheme;
  }

  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
        visualDensity: VisualDensity.standard,
        colorScheme: colorScheme,
        textTheme: TextThemes.textTheme(colorScheme),
        scaffoldBackgroundColor: appTheme.gray50,
        dividerTheme: DividerThemeData(
            thickness: 1, // Updated to more common value
            space: 1, // Updated to more common value
            color: appTheme.gray200));
  }

  LightCodeColors themeColor() => _getThemeColors();
  ThemeData themeData() => _getThemeData();
}

class TextThemes {
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
        bodyLarge: TextStyle(
            color: appTheme.blueGray400,
            fontSize: 16.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(
            color: appTheme.blueGray400,
            fontSize: 14.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400),
        bodySmall: TextStyle(
            color: appTheme.blueGray600,
            fontSize: 12.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(
            color: appTheme.blueGray900,
            fontSize: 24.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600),
        labelLarge: TextStyle(
            color: appTheme.gray900,
            fontSize: 12.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500),
        titleMedium: TextStyle(
            color: appTheme.black900,
            fontSize: 18.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600),
        titleSmall: TextStyle(
            color: appTheme.gray900,
            fontSize: 14.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500),
      );
}

class LightCodeColors {
  Color get black900 => const Color(0XFF000000);

  Color get blue50 => const Color(0XFFE0EBFF);
  Color get blueA700 => const Color(0XFF0061FF);

  Color get blueGray100 => const Color(0XFFD6DAE2);
  Color get blueGray300 => const Color(0XFF9EA8BA);
  Color get blueGray400 => const Color(0XFF74839D);
  Color get blueGray40001 => const Color(0XFF888888);
  Color get blueGray600 => const Color(0XFF5F6C86);
  Color get blueGray800 => const Color(0XFF3A4C63); // Added blueGray800
  Color get blueGray900 => const Color(0XFF262B35);

  Color get gray200 => const Color(0XFFEBEBEB);
  Color get gray30099 => const Color(0X99E4E4E4);
  Color get gray50 => const Color(0XFFFAFCFF);
  Color get gray60026 => const Color(0X155D5D5D);
  Color get gray70011 => const Color(0X11555555);
  Color get gray900 => const Color(0XFF09101D);
  Color get gray90001 => const Color(0XFF2A2A2A);
  Color get gray90002 => const Color(0XFF151522);

  Color get yellow700 => const Color.fromARGB(255, 255, 251, 0);
  Color get orange700 => const Color.fromARGB(255, 255, 140, 0);
  Color get green700 => const Color(0xFF2FD029);

  Color get red700 => const Color(0XFFD03329);

  Color get whiteA700 => const Color(0XFFFFFFFF);
}

class ColorSchemes {
  static var lightCodeColorScheme = ColorScheme.light(
    primary: LightCodeColors().blueA700,
    onPrimary: LightCodeColors().whiteA700,
    secondary: LightCodeColors().blueGray600,
    onSecondary: LightCodeColors().whiteA700,
    surface: LightCodeColors().whiteA700,
    onSurface: LightCodeColors().gray900,
    error: LightCodeColors().red700,
    onError: LightCodeColors().whiteA700,
    brightness: Brightness.light,
  );
}
