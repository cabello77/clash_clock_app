import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomePageScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const WelcomePageScreen({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Clash Clock App',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(onLoginSuccess: onLoginSuccess)),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 45),
              ),
              child: const Text('Login', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
                  ),
                ).then((value) {
                  // If registration was successful, user might want to login
                  // No automatic login after registration for security reasons
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 45),
              ),
              child: const Text('Register', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 30.0),
            OutlinedButton(
              onPressed: () {
                // Skip login and proceed as guest
                onLoginSuccess();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(200, 40),
              ),
              child: const Text(
                'Continue as Guest',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            const SizedBox(height: 50.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'This is an unofficial Pokémon fan app. Not affiliated with Nintendo or The Pokémon Company.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10, 
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
