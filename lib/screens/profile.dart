import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String displayName = 'User';
    if (user != null && user.email != null) {
      final email = user.email!;
      displayName = email.split('@')[0];
    }
    final backgroundColor = Theme.of(context).colorScheme.background;
    final onBackground = Theme.of(context).colorScheme.onBackground;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: onBackground)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: onBackground),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: onBackground),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: onBackground.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text("Hai, $displayName!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: onBackground,
                )),
          ],
        ),
      ),
    );
  }
}
