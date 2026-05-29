import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

//import 'screens/user/user_home.dart';
//import 'screens/auth/splash_screen.dart';
//import 'screens/expert/expert_home.dart';
import 'screens/expert/expert_support.dart';
//import 'screens/auth/input_password_baru.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SproutlyApp());
}

class SproutlyApp extends StatelessWidget {
  const SproutlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sproutly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF76D7EA),
        ),

        // Sebelumnya:
        // textTheme: GoogleFonts.outfitTextTheme(),

        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF0F4F3),
        useMaterial3: true,
      ),

      //home: HomeUserScreen(),
      //home: const SplashScreen(),
      //home: const SetNewPasswordScreen(),
      //home: const ExpertHomePage(),
      home: const ExpertSupportScreen(),
    );
  }
}
