import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// A widget that monitors network connectivity and:
/// 1. Shows a SnackBar when the device goes offline.
/// 2. Disables Firestore network access when offline or when the app is in background.
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper>
    with WidgetsBindingObserver {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial check
    _checkConnectivity();

    // Listen to changes
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // App is in background or inactive, disable network immediately
      FirebaseFirestore.instance.disableNetwork().catchError((_) {
        // Suppress errors during network disable
      });
    } else if (state == AppLifecycleState.resumed) {
      // App is back, re-enable network if we have connectivity
      if (!_isOffline) {
        FirebaseFirestore.instance.enableNetwork();
      }
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _updateConnectionStatus(results);
    } catch (_) {
      // Ignore errors during check
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // If none of the results indicate connection, we are offline
    final isOffline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);

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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are offline. Showing cached data.'),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleOnline() {
    // Re-enable Firestore
    FirebaseFirestore.instance.enableNetwork();

    // Show a message to the user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are back online.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
