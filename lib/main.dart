import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/pages/home_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick and Morty Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surface, // Mantém a cor original dos cards
        ),
        scaffoldBackgroundColor: const Color(
          0xFF000000,
        ), // APENAS o fundo da aplicação preto
        useMaterial3: true,
        textTheme:
            GoogleFonts.latoTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: AppColors.onPrimary,
                displayColor: AppColors.onPrimary,
              ),
            ).copyWith(
              displayLarge: GoogleFonts.lato(
                textStyle: AppTextStyles.displayLarge,
              ),
              displayMedium: GoogleFonts.lato(
                textStyle: AppTextStyles.displayMedium,
              ),
              headlineMedium: GoogleFonts.lato(
                textStyle: AppTextStyles.headlineMedium,
              ),
              titleMedium: GoogleFonts.lato(
                textStyle: AppTextStyles.titleMedium,
              ),
              bodyLarge: GoogleFonts.lato(textStyle: AppTextStyles.bodyLarge),
              bodyMedium: GoogleFonts.lato(textStyle: AppTextStyles.bodyMedium),
              bodySmall: GoogleFonts.lato(textStyle: AppTextStyles.bodySmall),
              labelMedium: GoogleFonts.lato(
                textStyle: AppTextStyles.labelMedium,
              ),
            ),
      ),
      home: const HomePage(),
    );
  }
}
