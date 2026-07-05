import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final DateFormat _dateFmt = DateFormat('d MMM yyyy');

class StatusDateField extends StatelessWidget {
  const StatusDateField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    required this.theme,
    this.isClearable = false,
    this.onCleared,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final ThemeData theme;
  final bool isClearable;
  final VoidCallback? onCleared;
  final String? errorText;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        onChanged(picked);
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: FaIcon(FontAwesomeIcons.calendar, size: 20),
          ),
        ),
        suffixIcon: isClearable && value != null
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.xmark, size: 18),
                onPressed: onCleared,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: errorText,
      ),
      child: Text(
        value == null ? 'Select Date' : _dateFmt.format(value!),
        style: value == null
            ? theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
            : theme.textTheme.bodyMedium,
      ),
    ),
  );
}
