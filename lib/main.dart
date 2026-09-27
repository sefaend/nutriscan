import 'package:flutter/material.dart';

void main() {
  runApp(const NutriScanApp());
}

class NutriScanApp extends StatelessWidget {
  const NutriScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NutriScan'),
        ),
        body: const Center(
          child: Text('NutriScan Hoş Geldiniz!'),
        ),
      ),
    );
  }
}