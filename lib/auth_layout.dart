import 'package:clash_clock/auth_service.dart';
import 'package:clash_clock/welcome_page_screen.dart';
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    this.pageIfConnected,
  });

  final Widget? pageIfConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authServiceValue, child) {
        return StreamBuilder(
          stream: authServiceValue.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasData) {
              return pageIfConnected ?? WelcomePageScreen(onLoginSuccess: () {  },) as Widget;
            } else {
              return const Scaffold(
                body: Center(
                  child: Text('Not connected'),
                ),
              );
            }
          },
        );
      },
    );
  }
}
