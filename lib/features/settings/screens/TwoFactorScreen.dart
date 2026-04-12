import 'package:flutter/material.dart';

class TwoFactorScreen extends StatelessWidget {
  const TwoFactorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
      ),
      body: const Center(
        child: Text('Two-Factor Authentication'),
      ),
    );
  }
}