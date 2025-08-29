import 'package:flutter/foundation.dart';
import 'dart:io';

class SpeedProvider with ChangeNotifier {
  double _downloadMbps = 0;
  double _uploadMbps = 0;
  bool _isTesting = false;

  double get downloadMbps => _downloadMbps;
  double get uploadMbps => _uploadMbps;
  bool get isTesting => _isTesting;

  Future<void> testSpeed({
    String testUrl = 'http://speedtest.tele2.net/1MB.zip',
  }) async {
    _isTesting = true;
    _downloadMbps = 0;
    _uploadMbps = 0;
    notifyListeners();

    try {
      final start = DateTime.now();
      final request = await HttpClient().getUrl(Uri.parse(testUrl));
      final response = await request.close();
      int totalBytes = 0;
      await for (var chunk in response) {
        totalBytes += chunk.length;
      }
      final end = DateTime.now();
      final seconds = end.difference(start).inMilliseconds / 1000;
      _downloadMbps = (totalBytes * 8 / 1000000) / seconds;
    } catch (e) {
      if (kDebugMode) print('Speed test error: $e');
    } finally {
      _isTesting = false;
      notifyListeners();
    }
  }
}
