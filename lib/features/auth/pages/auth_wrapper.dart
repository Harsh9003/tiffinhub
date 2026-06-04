import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

import '../../customer/pages/customer_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<UserModel?> _loadUserData(User user) {
    return AuthService.getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          return const LoginPage();
        }

        return FutureBuilder<UserModel?>(
          future: _loadUserData(firebaseUser),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final user = userSnapshot.data;

            if (user == null) {
              return const Scaffold(
                body: Center(
                  child: Text('User profile not found in Firestore. Please restart the app.'),
                ),
              );
            }

            if (!user.isActive) {
              return const _BlockedUserScreen();
            }

            return const CustomerDashboard();
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _BlockedUserScreen extends StatelessWidget {
  const _BlockedUserScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your account has been restricted. Please contact TiffinHub support.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}