import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class TracerouteProvider with ChangeNotifier {
  final List<String> _lines = [];
  List<String> get lines => _lines;

  bool _isTracing = false;
  bool get isTracing => _isTracing;

  Future<void> startTrace(String host) async {
    _lines.clear();
    _isTracing = true;
    notifyListeners();

    try {
      final isWindows = Platform.isWindows;
      final cmd = isWindows ? 'tracert' : 'traceroute';
      final args = isWindows ? [host] : ['-n', host];

      final process = await Process.start(cmd, args);

      await for (final line
          in process.stdout
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        final parsedLine = _parseLine(line, isWindows);
        if (parsedLine != null) {
          _lines.add(parsedLine);
          notifyListeners();
        }
      }

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final error = await process.stderr.transform(utf8.decoder).join();
        _lines.add('Error: $error');
        notifyListeners();
      }
    } catch (e) {
      _lines.add('Exception: $e');
      notifyListeners();
    } finally {
      _isTracing = false;
      notifyListeners();
    }
  }

  /// Satırı ayrıştır, RTT ve IP'yi netleştir
  /// Satırı ayrıştır, RTT ve IP'yi netleştir
  String? _parseLine(String line, bool isWindows) {
    try {
      if (isWindows) {
        // Örnek:  1    <1 ms    <1 ms    <1 ms  192.168.1.1
        final regex = RegExp(
          r'(\d+)\s+([<\d]+\s*ms)\s+([<\d]+\s*ms)\s+([<\d]+\s*ms)\s+([0-9.]+)',
        );
        final match = regex.firstMatch(line);
        if (match != null) {
          return 'Hop ${match.group(1)} | RTTs: ${match.group(2)}, ${match.group(3)}, ${match.group(4)} | IP: ${match.group(5)}';
        }
      } else {
        // Linux/macOS örnek: 1  192.168.1.1  1.123 ms  0.987 ms  1.001 ms
        final regex = RegExp(
          r'(\d+)\s+([0-9.]+)\s+([\d.]+ ms)\s+([\d.]+ ms)\s+([\d.]+ ms)',
        );
        final match = regex.firstMatch(line);
        if (match != null) {
          return 'Hop ${match.group(1)} | IP: ${match.group(2)} | RTTs: ${match.group(3)}, ${match.group(4)}, ${match.group(5)}';
        }
      }
    } catch (_) {}
    return null; // Eğer regex eşleşmezse ham satırı döndür
  }
}
