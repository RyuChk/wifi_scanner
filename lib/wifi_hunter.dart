import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';

class WiFiHunter {
  /// Method channel to communicate with the native Android Java functions
  static const MethodChannel _channel = MethodChannel('wifi_hunter');

  /// Start WiFi Scan
  static Future<WiFiHunterResult?> get huntWiFiNetworks async {
    final Map<String, dynamic> networks = Map<String, dynamic>.from(
        await _channel.invokeMethod('huntWiFiNetworks'));

    WiFiHunterResult result = WiFiHunterResult();

    List<String> ssids = List<String>.from(networks["SSIDS"]);
    List<String> bssids = List<String>.from(networks["BSSIDS"]);
    List<String> capabilities = List<String>.from(networks["CAPABILITES"]);
    List<int> frequencies = List<int>.from(networks["FREQUENCIES"]);
    List<int> levels = List<int>.from(networks["LEVELS"]);
    List<int> channelWidths = List<int>.from(networks["CHANNELWIDTHS"]);
    List<int> timestamps = List<int>.from(networks["TIMESTAMPS"]);

    for (var i = 0; i < ssids.length; i++) {
      result.results.add(WiFiHunterResultEntry(
          ssids[i],
          bssids[i],
          capabilities[i],
          frequencies[i],
          levels[i],
          channelWidths[i],
          timestamps[i]));
    }

    return result;
  }

  // Start WiFi scan with a timeout
  static Future<WiFiHunterResult?> huntWiFiNetworksWithTimeout(
      xinterval) async {
    final Completer<WiFiHunterResult?> completer =
    Completer<WiFiHunterResult?>();

    // Start WiFi scan
    final wifiScanFuture = huntWiFiNetworks;

    // Set a timeout for the WiFi scan operation (e.g., 10 seconds)
    final timeoutDuration = Duration(seconds: xinterval + 1);

    // Create a delayed Future to handle the timeout
    final timeoutFuture = Future.delayed(timeoutDuration, () {
      completer.completeError(TimeoutException('WiFi scan timed out'));
    });

    // Wait for either the WiFi scan to complete or the timeout to occur
    Future.any([wifiScanFuture, timeoutFuture]).then((result) {
      // Handle the result (it could be either WiFi scan result or TimeoutException)
      if (result is WiFiHunterResult) {
        completer.complete(result);
      }
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}