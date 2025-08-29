import 'dart:io';
import 'package:flutter/foundation.dart';

class SslProvider with ChangeNotifier {
  String _result = '';
  String get result => _result;

  bool _isChecking = false;
  bool get isChecking => _isChecking;

  Future<void> check(String host, {int port = 443}) async {
    _result = '';
    _isChecking = true;
    notifyListeners();

    try {
      final socket = await SecureSocket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      final cert = socket.peerCertificate;
      _result =
          'Issuer: ${cert!.issuer}\n'
          'Subject: ${cert!.subject}\n'
          'Start: ${cert.startValidity}\n'
          'End: ${cert.endValidity}\n'
          'Pem:\n${cert.pem}';
      socket.destroy();
    } catch (e) {
      _result = 'Error: $e';
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }
}
