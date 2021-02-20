import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData darkOld() {
    ColorScheme initialScheme = ColorScheme.dark();
    ColorScheme finalScheme = initialScheme.copyWith(
        onSurface: initialScheme.onSurface.withOpacity(.87),
        onBackground: initialScheme.onBackground.withOpacity(.87));
    ThemeData initialData = ThemeData.from(colorScheme: finalScheme);
    ThemeData finalData = initialData.copyWith(
        applyElevationOverlayColor: true,
        textTheme: initialData.textTheme.copyWith(
            headline1: GoogleFonts.poppins(
                fontSize: 93, fontWeight: FontWeight.w300, letterSpacing: -1.5),
            headline2: GoogleFonts.poppins(
                fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5),
            headline3:
                GoogleFonts.poppins(fontSize: 46, fontWeight: FontWeight.w400),
            headline4: GoogleFonts.poppins(
                fontSize: 33, fontWeight: FontWeight.w400, letterSpacing: 0.25),
            headline5: GoogleFonts.poppins(
                color: finalScheme.onSurface,
                fontSize: 23,
                fontWeight: FontWeight.w400),
            headline6: GoogleFonts.poppins(
                color: finalScheme.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15),
            caption: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: initialScheme.onSurface.withOpacity(.6))),
        iconTheme: initialData.iconTheme.copyWith(
            color: initialScheme.onSurface.withOpacity(0.87)), // dark theme
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: finalScheme.secondary)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)));
    return finalData;
  }

  static ThemeData fromScheme(ColorScheme initialScheme) {
    ColorScheme finalScheme = initialScheme.copyWith(
        background: Color.alphaBlend(
            initialScheme.primaryVariant.withOpacity(0.00),
            initialScheme.surface), //light theme
        onSurface: initialScheme.onSurface,
        onBackground: initialScheme.onBackground);
    ThemeData initialData = ThemeData.from(colorScheme: finalScheme);
    ThemeData finalData = initialData.copyWith(
        applyElevationOverlayColor: true,
        textTheme: initialData.textTheme.copyWith(
          headline1: GoogleFonts.lora(
              color: finalScheme.onSurface.withOpacity(.87),
              fontSize: 93,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.5),
          headline2: GoogleFonts.workSans(
              color: finalScheme.onSurface.withOpacity(.87),
              fontSize: 58,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.5),
          headline3: GoogleFonts.lora(
              color: finalScheme.onSurface.withOpacity(.87),
              fontSize: 46,
              fontWeight: FontWeight.bold),
          headline4: GoogleFonts.workSans(
              color: finalScheme.onSurface.withOpacity(.87),
              fontSize: 33,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25),
          headline5: GoogleFonts.workSans(
            color: finalScheme.onSurface.withOpacity(.87),
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
          headline6: GoogleFonts.lora(
              color: finalScheme.onSurface.withOpacity(.87),
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15),
          subtitle1: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: finalScheme.onSurface.withOpacity(.87),
          ),
          subtitle2: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: finalScheme.onSurface.withOpacity(.87)),
          caption: GoogleFonts.lora(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.4,
              color: finalScheme.onSurface.withOpacity(.6)),
          bodyText1: GoogleFonts.lora(
              color: finalScheme.onSurface.withOpacity(.87),
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500),
          bodyText2: GoogleFonts.rubik(
              color: finalScheme.onSurface.withOpacity(.87),
              fontSize: 14,
              height: 1.5),
        ),
        buttonBarTheme: initialData.buttonBarTheme.copyWith(
          buttonPadding: EdgeInsets.all(12),
        ),
        iconTheme: initialData.iconTheme
            .copyWith(color: initialScheme.onSurface.withOpacity(0.60)),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                primary: finalScheme.primary)), // light theme
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: finalScheme.secondary)),
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
    return fromScheme(ColorScheme.dark());
  }

  static ThemeData light() {
    return fromScheme(ColorScheme.light());
  }
}
