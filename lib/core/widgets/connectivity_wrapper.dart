import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../utils/snackbar_utils.dart';

/// A widget that monitors network connectivity and:
/// 1. Disables Firestore network access when offline or when the app is in background.
class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> with WidgetsBindingObserver {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial check
    _checkConnectivity();

    // Listen to changes
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    super.dispose();
  }

  // Handle app lifecycle changes (Background/Foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      return;
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App is in background or inactive, disable network immediately
      try {
        FirebaseFirestore.instance.disableNetwork();
      } catch (_) {}
    } else if (state == AppLifecycleState.resumed) {
      // App is back, re-enable network if we have connectivity
      if (!_isOffline) {
        try {
          FirebaseFirestore.instance.enableNetwork();
        } catch (_) {}
      }
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      _updateConnectionStatus(results);
    } catch (_) {
      // Ignore errors during check
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (!mounted) {
      return;
    }

    // If none of the results indicate connection, we are offline
    final bool isOffline =
        results.isEmpty || results.every((ConnectivityResult r) => r == ConnectivityResult.none);

    if (isOffline != _isOffline) {
      setState(() {
        _isOffline = isOffline;
      });

      if (_isOffline) {
        _handleOffline();
      } else {
        _handleOnline();
      }
    }
  }

  void _handleOffline() {
    // Disable Firestore to stop it from trying to reconnect aggressively
    FirebaseFirestore.instance.disableNetwork();

    // Show a message to the user
    SnackBarUtils.showWarning(context, 'You are offline. Some features may be unavailable.');
  }

  void _handleOnline() {
    // Re-enable Firestore
    FirebaseFirestore.instance.enableNetwork();

    // Show a message to the user
    SnackBarUtils.showSuccess(context, 'You are back online.');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
