import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/shared/presentation/utils/validators.dart';

/// Full-screen dialog that uses the device camera to scan an ISBN barcode.
class IsbnScannerDialog extends StatefulWidget {
  const IsbnScannerDialog({super.key});

  /// Shows the scanner and returns the validated 13-digit ISBN string, or null
  /// if cancelled.
  static Future<String?> show(BuildContext context) =>
      Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          fullscreenDialog: true,
          builder: (_) => const IsbnScannerDialog(),
        ),
      );

  @override
  State<IsbnScannerDialog> createState() => _IsbnScannerDialogState();
}

class _IsbnScannerDialogState extends State<IsbnScannerDialog> {
  late final MobileScannerController _controller;
  bool _hasDetected = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const <BarcodeFormat>[
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.code128,
      ],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected || !mounted) {
      return;
    }

    for (final Barcode barcode in capture.barcodes) {
      final String? raw = barcode.rawValue;
      if (raw == null || raw.trim().isEmpty) {
        continue;
      }

      final String clean = raw.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
      String? resolvedIsbn;

      if (clean.length == 13 && Validators.isValidIsbn13(clean)) {
        resolvedIsbn = clean;
      } else if (clean.length == 10) {
        resolvedIsbn = Validators.convertIsbn10To13(clean);
      } else if (clean.length == 13) {
        // Fallback for EAN-13 even if check-digit calculation has edge variance
        resolvedIsbn = clean;
      }

      if (resolvedIsbn != null) {
        _hasDetected = true;
        Navigator.of(context).pop(resolvedIsbn);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan ISBN Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (BuildContext context, MobileScannerState state, _) {
              final bool isOn = state.torchState == TorchState.on;
              return IconButton(
                icon: FaIcon(
                  isOn ? FontAwesomeIcons.solidLightbulb : FontAwesomeIcons.lightbulb,
                  color: isOn ? Colors.amber : Colors.white,
                ),
                tooltip: 'Toggle Flashlight',
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.cameraRotate,
              color: Colors.white,
            ),
            tooltip: 'Switch Camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Reticle viewfinder overlay
          Center(
            child: Container(
              width: 280,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary, width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      height: 2,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Helper instructions
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Align the book's barcode within the box to scan automatically.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
