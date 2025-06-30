import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login.dart';
import 'services/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeModeBuilder(
      builder: (context, themeMode) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            background: Color(0xFFFCFCF7),
            primary: Color(0xFF111111),
            secondary: Color(0xFF111111),
            surface: Color(0xFFFFFFF0),
            onBackground: Color(0xFF111111),
            onPrimary: Color(0xFF111111),
            onSecondary: Color(0xFF111111),
            onSurface: Color(0xFF111111),
          ),
          scaffoldBackgroundColor: const Color(0xFFFCFCF7),
          canvasColor: const Color(0xFFFFFFF0),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFCFCF7),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF111111)),
            titleTextStyle: TextStyle(color: Color(0xFF111111), fontWeight: FontWeight.bold, fontSize: 20),
          ),
          cardColor: Color(0xFFFFFFF0),
          dialogBackgroundColor: Color(0xFFFFFFF0),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            background: Color(0xFF161110),
            primary: Color(0xFFFFFFFF),
            secondary: Color(0xFFFFFFFF),
            surface: Color(0xFF21242A),
            onBackground: Color(0xFFFFFFFF),
            onPrimary: Color(0xFFFFFFFF),
            onSecondary: Color(0xFFFFFFFF),
            onSurface: Color(0xFFFFFFFF),
          ),
          scaffoldBackgroundColor: const Color(0xFF161110),
          canvasColor: const Color(0xFF21242A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF161110),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          cardColor: Color(0xFF21242A),
          dialogBackgroundColor: Color(0xFF21242A),
        ),
        themeMode: themeMode,
        home: LoginScreen(),
      ),
    );
  }
}