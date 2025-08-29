import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class WhoisProvider with ChangeNotifier {
  String _result = '';
  String get result => _result;

  bool _isQuerying = false;
  bool get isQuerying => _isQuerying;

  Future<void> lookup(String domain) async {
    _isQuerying = true;
    _result = '';
    notifyListeners();

    try {
      final socket = await Socket.connect(
        'whois.verisign-grs.com',
        43,
        timeout: const Duration(seconds: 5),
      );
      socket.write('$domain\r\n');

      // Dart 3 uyumlu çözüm
      final response = await socket
          .map((event) => event.toList()) // Uint8List -> List<int>
          .transform(utf8.decoder) // Stream<String>
          .join();

      _result = response;

      await socket.close();
    } catch (e) {
      _result = 'Error: $e';
    } finally {
      _isQuerying = false;
      notifyListeners();
    }
  }
}
