import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      //NOT NEEDED JUST FOR TESTING
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'PROFILE SCREEN',
          style: TextStyle(color: Colors.black, fontSize: 50),
        ),
        SizedBox(height: 10),
        OutlinedButton(
          onPressed: () async {
            context.push(AppRoutes.login);
          },
          child: Text('Login Test Button'),
        ),
        OutlinedButton(
          onPressed: () async {
            context.push(AppRoutes.signup);
          },
          child: Text('Sign Up Test Button'),
        ),
      ],
    );
  }
}
