import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

class PingResult {
  final String ip;
  final Duration? time;
  final int? ttl;
  final int seq;
  final int size;

  PingResult({
    required this.ip,
    this.time,
    this.ttl,
    required this.seq,
    required this.size,
  });
}

class PingProvider with ChangeNotifier {
  final List<PingResult> _responses = [];
  List<PingResult> get responses => _responses;

  bool _isPinging = false;
  bool get isPinging => _isPinging;

  int _packetCount = 0;
  int get packetCount => _packetCount;

  int get packetsSent => _packetCount;
  int get packetsReceived =>
      _responses.where((r) => r.time != null).length; // yanıt alınan
  int get packetsLost => packetsSent - packetsReceived;
  double get packetLossPercentage =>
      packetsSent == 0 ? 0 : packetsLost / packetsSent * 100;

  double get minTime => _responses
      .where((r) => r.time != null)
      .map((r) => r.time!.inMilliseconds)
      .fold<double>(
        double.infinity,
        (prev, elem) => elem < prev ? elem.toDouble() : prev,
      )
      .clamp(0, double.infinity);

  double get maxTime => _responses
      .where((r) => r.time != null)
      .map((r) => r.time!.inMilliseconds)
      .fold<double>(0, (prev, elem) => elem > prev ? elem.toDouble() : prev);

  double get avgTime {
    final validTimes = _responses
        .where((r) => r.time != null)
        .map((r) => r.time!.inMilliseconds);
    if (validTimes.isEmpty) return 0;
    return validTimes.reduce((a, b) => a + b) / validTimes.length;
  }

  Future<void> startPing(
    String host, {
    int count = 1,
    int timeoutSeconds = 2,
    int packetSize = 32,
    bool clearPrevious = false,
  }) async {
    if (clearPrevious) {
      _responses.clear();
      _packetCount = 0;
    }

    _isPinging = true;
    notifyListeners();

    for (var i = 1; i <= count; i++) {
      _packetCount++;
      notifyListeners();

      try {
        final ping = Ping(host, count: 1, timeout: timeoutSeconds);
        PingResult result = PingResult(
          ip: host,
          time: null, // default olarak null
          ttl: null,
          seq: i,
          size: packetSize,
        );

        await for (final event in ping.stream) {
          if (event.response != null) {
            final resp = event.response!;
            result = PingResult(
              ip: resp.ip ?? host,
              time: resp.time,
              ttl: resp.ttl,
              seq: i,
              size: packetSize,
            );
          }
        }
        _responses.add(result);
        notifyListeners();
      } catch (e) {
        // ping hatası olsa da paket sayısı artar, yanıt null kalır
        _responses.add(
          PingResult(ip: host, time: null, ttl: null, seq: i, size: packetSize),
        );
        notifyListeners();
      }

      await Future.delayed(Duration(seconds: 1));
    }

    _isPinging = false;
    notifyListeners();
  }

  void clearResponses() {
    _responses.clear();
    _packetCount = 0;
    notifyListeners();
  }
}
