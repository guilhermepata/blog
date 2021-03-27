import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static Color primaryLight = Color(0xff5500e8);
  static Color primaryVariantLight = Color(0xff0000b4);
  static Color secondaryLight = Color(0xffAC53D8);
  static Color secondaryVariantLight = Color(0xff7920a6);

  // static Color primaryDark = Color(0xffB995F6);
  static Color primaryDark = Color(0xffB895F6);
  static Color primaryVariantDark = Color(0xff8767c3);
  static Color secondaryDark = Color(0xffCE9BE8);
  static Color secondaryVariantDark = Color(0xff9c6cb6);

  static TextTheme appTextTheme({required ColorScheme finalScheme}) {
    final data = ThemeData.from(colorScheme: finalScheme);
    return data.textTheme.copyWith(
      headline1: GoogleFonts.lora(
        color: finalScheme.onSurface.withOpacity(.87),
        fontSize: 93,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        wordSpacing: -1.5,
      ),
      headline2: GoogleFonts.workSans(
        color: finalScheme.onSurface.withOpacity(.87),
        fontSize: 58,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      headline3: GoogleFonts.lora(
        color: finalScheme.onSurface.withOpacity(.87),
        fontSize: 46,
        fontWeight: FontWeight.bold,
      ),
      headline4: GoogleFonts.workSans(
        color: finalScheme.onSurface.withOpacity(.87),
        fontSize: 33,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      headline5: GoogleFonts.workSans(
        color: finalScheme.onSurface.withOpacity(.87),
        fontSize: 23,
        fontWeight: FontWeight.bold,
      ),
      headline6: GoogleFonts.rubik(
        color: finalScheme.onSurface.withOpacity(.87),
        fontSize: 19,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      subtitle1: GoogleFonts.rubik(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: finalScheme.onSurface.withOpacity(.87),
      ),
      subtitle2: GoogleFonts.ibmPlexSerif(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: finalScheme.onSurface.withOpacity(.87),
      ),
      caption: GoogleFonts.rubik(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.4,
        color: finalScheme.onSurface.withOpacity(.6),
      ),
      bodyText1: GoogleFonts.ibmPlexSerif(
        color: finalScheme.onSurface.withOpacity(.87),
        fontSize: 17,
        height: 2,
        fontWeight: FontWeight.w400,
      ),
      bodyText2: GoogleFonts.rubik(
        color: finalScheme.onSurface.withOpacity(.87),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      button: GoogleFonts.rubik(
        color: finalScheme.onSurface.withOpacity(.87),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ThemeData fromScheme(ColorScheme initialScheme) {
    ColorScheme finalScheme = initialScheme.copyWith(
        // surface: Color.alphaBlend(
        //     initialScheme.secondary.withOpacity(0.5), initialScheme.surface),
        onSurface: initialScheme.onSurface,
        onBackground: initialScheme.onBackground);
    TextTheme textTheme = appTextTheme(finalScheme: finalScheme);
    ThemeData initialData =
        ThemeData.from(colorScheme: finalScheme, textTheme: textTheme);
    ThemeData finalData = initialData.copyWith(
        applyElevationOverlayColor: true,
        buttonBarTheme: initialData.buttonBarTheme.copyWith(
          buttonPadding: EdgeInsets.all(12),
        ),
        iconTheme: initialData.iconTheme
            .copyWith(color: initialScheme.onSurface.withOpacity(0.60)),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                primary: finalScheme.primary)), // light theme
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                primary: finalScheme.secondary, padding: EdgeInsets.all(8))),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)));
    return finalData.copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: initialScheme.surface,
            textTheme: finalData.textTheme,
            foregroundColor: finalScheme.onSurface.withOpacity(.87),
            backwardsCompatibility: false),
        cardColor: Color.alphaBlend(
            initialScheme.primaryVariant.withOpacity(0.00),
            initialScheme.surface));
  }

  static ThemeData dark() {
    return fromScheme(ColorScheme.dark().copyWith(
        primary: primaryDark,
        primaryVariant: primaryVariantDark,
        secondary: secondaryDark,
        secondaryVariant: secondaryVariantDark));
  }

  static ThemeData light() {
    return fromScheme(ColorScheme.light().copyWith(
        primary: primaryLight,
        primaryVariant: primaryVariantLight,
        secondary: secondaryLight,
        secondaryVariant: secondaryVariantLight,
        background:
            Color.alphaBlend(Colors.black.withOpacity(0.05), Colors.white)));
  }
}
