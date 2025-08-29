import 'package:flutter/foundation.dart';
import 'dart:math';

class SubnetProvider with ChangeNotifier {
  String _result = '';
  String get result => _result;

  void calculate(String input) {
    try {
      // input: 192.168.1.0/24
      final parts = input.split('/');
      if (parts.length != 2) throw 'Invalid format';

      final ipParts = parts[0].split('.').map(int.parse).toList();
      final prefix = int.parse(parts[1]);
      if (ipParts.length != 4 || prefix < 0 || prefix > 32)
        throw 'Invalid IP or prefix';

      final mask = List<int>.filled(4, 0);
      int remaining = prefix;
      for (int i = 0; i < 4; i++) {
        if (remaining >= 8) {
          mask[i] = 255;
          remaining -= 8;
        } else if (remaining > 0) {
          mask[i] = 256 - pow(2, 8 - remaining).toInt();
          remaining = 0;
        }
      }

      // Network Address
      final network = List<int>.generate(4, (i) => ipParts[i] & mask[i]);

      // Broadcast Address
      final broadcast = List<int>.generate(
        4,
        (i) => network[i] | (~mask[i] & 0xFF),
      );

      // Host count
      final hosts = pow(2, 32 - prefix) - 2;

      _result =
          'Network: ${network.join('.')}\n'
          'Broadcast: ${broadcast.join('.')}\n'
          'Subnet Mask: ${mask.join('.')}\n'
          'Hosts: $hosts';
    } catch (e) {
      _result = 'Error: $e';
    }
    notifyListeners();
  }
}
