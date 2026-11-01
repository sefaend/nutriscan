import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //NOT NEEDED JUST FOR TESTING

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'HOME SCREEN',
          style: TextStyle(color: Colors.black, fontSize: 50),
        ),
      ],
    );
  }
}
