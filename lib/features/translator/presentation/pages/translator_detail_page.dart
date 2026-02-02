import 'package:flutter/material.dart';

class TranslatorDetailPage extends StatelessWidget {
  const TranslatorDetailPage({super.key, required this.translatorId});
  final String translatorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translator Details')),
      body: Center(child: Text('Translator ID: $translatorId')),
    );
  }
}
