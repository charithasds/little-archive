import 'package:flutter/material.dart';

import './detail_tile.dart';

class InfoDialogMetadata extends StatelessWidget {
  const InfoDialogMetadata({required this.created, required this.updated, super.key});

  final DateTime created;
  final DateTime updated;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      DetailTile(
        label: 'Created',
        value: DetailTile.formatDate(created),
        leadingIcon: Icons.calendar_today_rounded,
      ),
      DetailTile(
        label: 'Last Updated',
        value: DetailTile.formatDate(updated),
        leadingIcon: Icons.update_rounded,
      ),
    ],
  );
}
