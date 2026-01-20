import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShortDetailPage extends ConsumerWidget {
  final String shortId;

  const ShortDetailPage({super.key, required this.shortId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Short Detail')),
      body: Center(
        child: Text('Short ID: $shortId\n(Detail Page Placeholder)'),
      ),
    );
  }
}
