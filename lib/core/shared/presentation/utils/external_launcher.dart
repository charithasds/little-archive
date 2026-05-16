import 'package:url_launcher/url_launcher.dart';

import '../utils/snack_bars.dart';

class ExternalLauncher {
  static Future<void> launchBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      // On web and some platforms, launchUrl is more reliable than checking canLaunchUrl first
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        SnackBars.showError('Could not launch $url');
      }
    } catch (e) {
      SnackBars.showError('Error launching browser: $e');
    }
  }

  static Future<void> launchEmail(String email) async {
    try {
      final Uri uri = Uri(scheme: 'mailto', path: email);
      final bool launched = await launchUrl(uri);
      if (!launched) {
        SnackBars.showError('Could not launch email client for $email');
      }
    } catch (e) {
      SnackBars.showError('Error launching email: $e');
    }
  }

  static Future<void> launchPhone(String phoneNumber) async {
    try {
      final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
      final bool launched = await launchUrl(uri);
      if (!launched) {
        SnackBars.showError('Could not launch phone app for $phoneNumber');
      }
    } catch (e) {
      SnackBars.showError('Error launching phone: $e');
    }
  }
}
