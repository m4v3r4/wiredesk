import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class WolProvider with ChangeNotifier {
  bool _isSending = false;
  bool get isSending => _isSending;

  Future<void> sendMagicPacket(String mac, String broadcast) async {
    _isSending = true;
    notifyListeners();

    try {
      final macBytes = mac
          .split(':')
          .map((e) => int.parse(e, radix: 16))
          .toList();
      final packet = Uint8List(102);

      // 6x 0xFF
      for (int i = 0; i < 6; i++) {
        packet[i] = 0xFF;
      }

      // MAC adresini 16 kez tekrar et
      for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 6; j++) {
          packet[6 + i * 6 + j] = macBytes[j];
        }
      }

      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      socket.send(packet, InternetAddress(broadcast), 9);
      socket.close();
    } catch (e) {
      if (kDebugMode) print('WOL Error: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
