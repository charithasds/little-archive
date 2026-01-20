import 'package:flutter/material.dart';

class TranslatorDetailPage extends StatelessWidget {
  final String translatorId;
  const TranslatorDetailPage({super.key, required this.translatorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translator Details')),
      body: Center(child: Text('Translator ID: $translatorId')),
    );
  }
}
