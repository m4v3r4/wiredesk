import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class Device {
  final String ip;
  String? mac;
  bool isAlive;
  int? pingTime; // ms
  String? osGuess;
  List<int> openPorts = [];
  Map<int, String> portBanners = {};

  Device({
    required this.ip,
    this.mac,
    required this.isAlive,
    this.pingTime,
    this.osGuess,
  });

  @override
  String toString() {
    return 'Device(ip: $ip, mac: ${mac ?? 'Unknown'}, alive: $isAlive, ping: ${pingTime ?? '-'} ms, OS: ${osGuess ?? '-'})';
  }
}

class NetworkScannerProvider with ChangeNotifier {
  final List<Device> _devices = [];
  List<Device> get devices => List.unmodifiable(_devices);

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _cancelScan = false;

  // İstatistikler
  int get totalIPs => _devices.length;
  int get aliveCount => _devices.where((d) => d.isAlive).length;
  int get deadCount => _devices.where((d) => !d.isAlive).length;
  double get avgPing {
    final alivePings = _devices
        .where((d) => d.pingTime != null)
        .map((d) => d.pingTime!);
    if (alivePings.isEmpty) return 0;
    return alivePings.reduce((a, b) => a + b) / alivePings.length;
  }

  // Tarama başlat
  Future<void> scanNetwork(String baseIp, {int concurrency = 20}) async {
    _devices.clear();
    _isScanning = true;
    _cancelScan = false;
    notifyListeners();
    print('Scan started on base IP: $baseIp');

    final ipQueue = List.generate(254, (i) => '$baseIp.${i + 1}');
    final List<Future> activeFutures = [];

    while (ipQueue.isNotEmpty && !_cancelScan) {
      while (activeFutures.length < concurrency && ipQueue.isNotEmpty) {
        final ip = ipQueue.removeAt(0);

        late Future<void> future;
        future = _pingThenCollect(ip).whenComplete(() {
          activeFutures.remove(future);
        });

        activeFutures.add(future);
      }
      if (activeFutures.isNotEmpty) {
        await Future.any(activeFutures);
      }
    }

    await Future.wait(activeFutures);

    _isScanning = false;
    notifyListeners();
    print('Scan completed. Total devices scanned: ${_devices.length}');
  }

  void cancelScan() {
    _cancelScan = true;
    _isScanning = false;
    notifyListeners();
    print('Scan cancelled.');
  }

  // Ping at ve yanıt varsa MAC, OS ve port bilgilerini topla
  Future<void> _pingThenCollect(String ip) async {
    try {
      final stopwatch = Stopwatch()..start();
      ProcessResult pingResult;

      if (Platform.isWindows) {
        pingResult = await Process.run('ping', ['-n', '1', '-w', '1000', ip]);
      } else {
        pingResult = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
      }

      stopwatch.stop();
      bool alive = pingResult.exitCode == 0;
      int? pingTime = alive ? stopwatch.elapsedMilliseconds : null;
      String? mac;
      String? os;

      if (alive) {
        mac = await _getMac(ip);
        os = _guessOS(pingResult.stdout.toString());
      }

      final device = Device(
        ip: ip,
        mac: mac,
        isAlive: alive,
        pingTime: pingTime,
        osGuess: os,
      );

      _devices.add(device);
      notifyListeners();

      // Canlı cihazlarda port taraması yap
      if (alive) {
        await _scanPorts(device);
        notifyListeners();
      }

      print('Device found: $device');
    } catch (e) {
      _devices.add(Device(ip: ip, isAlive: false));
      print('Error pinging $ip: $e');
      notifyListeners();
    }
  }

  // MAC adresini al
  Future<String?> _getMac(String ip) async {
    try {
      ProcessResult arpResult;
      if (Platform.isWindows) {
        arpResult = await Process.run('arp', ['-a', ip]);
      } else {
        arpResult = await Process.run('arp', ['-n', ip]);
      }
      final output = arpResult.stdout.toString();
      final match = RegExp(
        r'([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})',
      ).firstMatch(output);
      return match?.group(0);
    } catch (e) {
      print('Error getting MAC for $ip: $e');
      return null;
    }
  }

  // Basit OS tahmini TTL üzerinden
  String? _guessOS(String pingOutput) {
    final ttlMatch = RegExp(r'ttl=(\d+)').firstMatch(pingOutput);
    if (ttlMatch != null) {
      final ttl = int.tryParse(ttlMatch.group(1)!);
      if (ttl != null) {
        if (ttl >= 128) return 'Windows';
        if (ttl <= 64) return 'Linux/macOS';
        return 'Unknown';
      }
    }
    return null;
  }

  // Port tarama ve basit banner okuma
  Future<void> _scanPorts(Device device) async {
    final ports = [22, 80, 443, 8080]; // örnek port listesi
    for (var port in ports) {
      try {
        final socket = await Socket.connect(
          device.ip,
          port,
          timeout: const Duration(seconds: 2),
        );
        socket.destroy();
        device.openPorts.add(port);

        // Basit banner: sadece port açık bilgisi
        device.portBanners[port] = 'Open';
      } catch (_) {
        // Port kapalı veya timeout
      }
    }
  }
}
