import 'dart:io';
import 'package:flutter/foundation.dart';

class DnsProvider with ChangeNotifier {
  List<String> _records = [];
  List<String> get records => _records;

  bool _isLookingUp = false;
  bool get isLookingUp => _isLookingUp;

  Future<void> lookup(String host) async {
    _records.clear();
    _isLookingUp = true;
    notifyListeners();

    try {
      final addresses = await InternetAddress.lookup(host);
      for (var addr in addresses) {
        _records.add(addr.address);
      }
    } catch (e) {
      _records.add('Error: $e');
    } finally {
      _isLookingUp = false;
      notifyListeners();
    }
  }
}
