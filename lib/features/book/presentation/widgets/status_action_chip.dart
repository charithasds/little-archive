import 'package:flutter/material.dart';

class StatusActionChip extends StatelessWidget {
  const StatusActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 16, color: color),
    label: Text(label),
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    backgroundColor: color.withValues(alpha: 0.1),
    side: BorderSide(color: color.withValues(alpha: 0.3)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    onPressed: onTap,
  );
}
