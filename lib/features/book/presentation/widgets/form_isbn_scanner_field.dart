import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/shared/presentation/utils/validators.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import 'isbn_scanner_dialog.dart';

/// An ISBN form field that has the identical height, styling, and behavior
/// as other form fields. Users can type manually or tap the camera icon
/// in the suffix to scan the barcode.
class FormIsbnScannerField extends ConsumerWidget {
  const FormIsbnScannerField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  Future<void> _scan(BuildContext context) async {
    final String? scanned = await IsbnScannerDialog.show(context);
    if (scanned != null && scanned.isNotEmpty) {
      controller.text = scanned;
      onChanged?.call(scanned);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => FormTextField(
      controller: controller,
      label: 'ISBN',
      hint: 'e.g. 9789553031358',
      prefixIcon: FontAwesomeIcons.barcode,
      maxLength: 13,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      validator: Validators.validateIsbn,
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (BuildContext context, TextEditingValue value, _) {
          final String text = value.text.trim();
          final bool hasValue = text.isNotEmpty;
          final String clean = text.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
          final bool isValid = hasValue && Validators.isValidIsbn13(clean);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (hasValue)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    isValid ? '🟢' : '🔴',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.camera, size: 18),
                tooltip: 'Scan ISBN Barcode',
                onPressed: () => _scan(context),
              ),
            ],
          );
        },
      ),
    );
}
