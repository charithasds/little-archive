import 'package:flutter/material.dart';

class SequenceDetailPage extends StatelessWidget {
  const SequenceDetailPage({super.key, required this.sequenceId});
  final String sequenceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sequence Details')),
      body: Center(child: Text('Sequence ID: $sequenceId')),
    );
  }
}
