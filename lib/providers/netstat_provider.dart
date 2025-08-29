import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class NetstatProvider with ChangeNotifier {
  List<String> _connections = [];
  List<String> get connections => _connections;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  Future<void> fetchConnections() async {
    _connections.clear();
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Komut seçimi
      final cmd = Platform.isWindows ? 'netstat' : 'ss';
      final args = Platform.isWindows ? ['-n'] : ['-a'];

      // Komut var mı kontrol
      final checkCmd = Platform.isWindows ? 'where' : 'which';
      final checkResult = await Process.run(checkCmd, [cmd]);
      if (checkResult.exitCode != 0) {
        _error = '$cmd komutu bulunamadı!';
        _connections = [_error];
        return;
      }
      print('Debug: Komut seçildi -> $cmd');
      print('Debug: Check command exitCode: ${checkResult.exitCode}');
      print('Debug: Check command stdout: ${checkResult.stdout}');
      print('Debug: Check command stderr: ${checkResult.stderr}');

      // Komutu başlat
      final process = await Process.start(cmd, args);

      final output = <String>[];
      final errorOutput = <String>[];

      // stdout'u oku ve anlık notify
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            output.add(line);
            notifyListeners(); // UI anlık güncellensin
          });

      // stderr'i oku
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            errorOutput.add(line);
            print('Debug stderr line: $line');
          });

      // process bitene kadar bekle
      final exitCode = await process.exitCode;
      print('Debug: Process exitCode: $exitCode');

      _connections = output.isNotEmpty
          ? output
          : ['Komut çalıştırıldı ama çıktı yok'];
      if (errorOutput.isNotEmpty) {
        _connections.addAll(errorOutput);
      }
    } catch (e) {
      _error = 'Error: $e';
      _connections = [_error];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
