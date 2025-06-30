import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> saveLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
  }

  Future<void> _register() async {
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await saveLogin(result.user?.email ?? '');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Register Gagal: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _login() async {
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await saveLogin(result.user?.email ?? '');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  final AuthServices authServices = AuthServices();
  Future<void> _handleSigninWithGoogle() async {
    try {
      print('Initiating Google Sign-In from UI...');
      final userCredential = await authServices.signInWithGoogle();
      if (userCredential != null) {
        print('Google Sign-In successful, saving login...');
        await saveLogin(userCredential.user?.email ?? '');
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(),
            ),
          );
        }
      } else {
        print('Google Sign-In returned null');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal masuk dengan Google. Silakan coba lagi.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _handleSigninWithGoogle: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.background;
    final accentColor = Theme.of(context).colorScheme.primary;
    final onBackground = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "SchedUni.",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabButton("Login", isLogin, () {
                      setState(() {
                        isLogin = true;
                      });
                    }),
                    _buildTabButton("Register", !isLogin, () {
                      setState(() {
                        isLogin = false;
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 30),
                // Username
                TextField(
                  controller: _usernameController,
                  style: TextStyle(fontSize: 15, color: onBackground),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: onBackground),
                    hintText: "Email",
                    hintStyle: TextStyle(color: onBackground.withOpacity(0.5)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: onBackground.withOpacity(0.3)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(fontSize: 15, color: onBackground),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: onBackground),
                    hintText: "Password",
                    hintStyle: TextStyle(color: onBackground.withOpacity(0.5)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: onBackground.withOpacity(0.3)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: onBackground),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (isLogin) {
                      _login();
                    } else {
                      _register();
                    }
                  },
                  child: Text(
                    isLogin ? "Login" : "Register",
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white, 
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    _handleSigninWithGoogle();
                  },
                  child: Text(
                    'Login with Google',
                    style: TextStyle(
                      color: onBackground.withOpacity(0.7),
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(
      String title, bool isActive, VoidCallback onPressed) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final onBackground = Theme.of(context).colorScheme.onBackground;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isActive ? accentColor : Colors.transparent,
          foregroundColor: isActive ? (isDark ? Colors.black : Colors.white) : onBackground,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: accentColor, width: 1),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? (isDark ? Colors.black : Colors.white) : onBackground,
          ),
        ),
      ),
    );
  }
}
