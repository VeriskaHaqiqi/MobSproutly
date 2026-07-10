import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/article_provider.dart';
import 'providers/consultation_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/expert_provider.dart';
import 'services/api_client.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi ApiClient (Dio interceptor dll)
  ApiClient().init();

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

// Lets screens react when they become visible again after another screen
// on top of them is popped (e.g. coming back from the payment screen to
// the consultations list) -- used to refresh data that may have changed
// elsewhere in the meantime, instead of only fetching once in initState.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class SproutlyApp extends StatelessWidget {
  const SproutlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => ExpertProvider()),
      ],
      child: MaterialApp(
        title: 'Sproutly',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF76D7EA),
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF0F4F3),
          useMaterial3: true,
          splashFactory: NoSplash.splashFactory,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}