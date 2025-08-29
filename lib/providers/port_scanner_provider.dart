import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class PortScannerProvider with ChangeNotifier {
  List<String> openPorts = [];
  List<String> scanLogs = [];
  bool isScanning = false;
  double _progress = 0.0;
  double get progress => _progress;
  Map<int, Map<String, String>> portDetails = {};

  Future<void> startScan(
    String host,
    int start,
    int end, {
    bool serviceVersionScan = false,
    Function(int port, bool isOpen, String service, String banner)? onPortFound,
  }) async {
    openPorts.clear();
    scanLogs.clear();
    portDetails.clear();
    isScanning = true;
    _progress = 0.0;
    notifyListeners();

    scanLogs.add('Tarama başlatıldı: $host, port $start-$end');
    notifyListeners();

    for (int port = start; port <= end; port++) {
      bool isOpen = false;
      String banner = '';
      String service = 'Unknown';

      try {
        isOpen = await checkPort(host, port);

        if (isOpen) {
          if (serviceVersionScan) {
            banner = await getBanner(host, port);
            if (banner.isNotEmpty) {
              service = parseServiceFromBanner(banner);
            }
          }
          openPorts.add(port.toString());
          portDetails[port] = {'service': service, 'banner': banner};
        }
      } catch (_) {
        // hata olursa service/banner boş kalır
      }

      scanLogs.add(
        'Port $port: ${isOpen ? "Açık" : "Kapalı"} ($service) ${banner.isNotEmpty ? "| Banner: $banner" : ""}',
      );

      if (isOpen && onPortFound != null) {
        onPortFound(port, isOpen, service, banner);
      }

      _progress = (port - start + 1) / (end - start + 1);
      notifyListeners();
    }

    scanLogs.add('Tarama tamamlandı. Açık portlar: ${openPorts.join(", ")}');
    isScanning = false;
    _progress = 1.0;
    notifyListeners();
  }

  Future<bool> checkPort(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(milliseconds: 300),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  String parseServiceFromBanner(String banner) {
    if (banner.isEmpty) return 'Unknown';

    final b = banner.toLowerCase();

    if (b.contains('http')) {
      // HTTP/1.1 200 OK veya Server: nginx/1.23.1 gibi
      final serverMatch = RegExp(r'Server: ([^\r\n]+)').firstMatch(banner);
      return serverMatch != null ? 'HTTP (${serverMatch.group(1)})' : 'HTTP';
    } else if (b.contains('ftp')) {
      return 'FTP';
    } else if (b.contains('ssh')) {
      return 'SSH';
    } else if (b.contains('smtp')) {
      return 'SMTP';
    } else if (b.contains('pop3')) {
      return 'POP3';
    } else if (b.contains('imap')) {
      return 'IMAP';
    }

    return 'Unknown';
  }

  /// Banner grabbing (gelişmiş, Nmap benzeri)
  Future<String> getBanner(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 2),
      );

      // HTTP için HEAD isteği
      if (port == 80 || port == 8080) {
        socket.write('HEAD / HTTP/1.0\r\nHost: $host\r\n\r\n');
      }

      final buffer = <int>[];
      final completer = Completer<void>();

      socket.listen(
        (data) {
          buffer.addAll(data);
        },
        onDone: () => completer.complete(),
        onError: (_) => completer.complete(),
        cancelOnError: true,
      );

      // Maksimum 2 saniye veya bağlantı kapanana kadar bekle
      await Future.any([
        completer.future,
        Future.delayed(const Duration(seconds: 2)),
      ]);

      socket.destroy();

      if (buffer.isEmpty) return '';
      return utf8.decode(buffer).trim();
    } catch (_) {
      return '';
    }
  }
}
