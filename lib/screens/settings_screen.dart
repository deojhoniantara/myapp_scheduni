import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
    // Notifikasi ke root agar theme berubah
    ThemeModeNotifier.of(context)?.setDarkMode(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema Gelap'),
            value: isDarkMode,
            onChanged: _toggleTheme,
          ),
        ],
      ),
    );
  }
}

// Notifier untuk themeMode global
class ThemeModeNotifier extends InheritedWidget {
  final _ThemeModeNotifierState data;
  const ThemeModeNotifier({required Widget child, required this.data}) : super(child: child);
  static _ThemeModeNotifierState? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ThemeModeNotifier>()?.data;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class ThemeModeBuilder extends StatefulWidget {
  final Widget Function(BuildContext, ThemeMode) builder;
  const ThemeModeBuilder({required this.builder});
  @override
  _ThemeModeNotifierState createState() => _ThemeModeNotifierState();
}

class _ThemeModeNotifierState extends State<ThemeModeBuilder> {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void setDarkMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
    });
  }
  @override
  Widget build(BuildContext context) {
    return ThemeModeNotifier(
      data: this,
      child: widget.builder(context, _themeMode),
    );
  }
} 