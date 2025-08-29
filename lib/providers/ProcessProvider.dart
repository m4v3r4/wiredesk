import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProcessProvider with ChangeNotifier {
  bool _isProcessing = false;
  String _message = '';
  List<String> _logs = [];

  bool get isProcessing => _isProcessing;
  String get message => _message;
  List<String> get logs => List.unmodifiable(_logs);

  void start(String msg) {
    _message = msg;
    _isProcessing = true;
    _logs.clear();
    notifyListeners();
  }

  void addLog(String log) {
    _logs.add(log);
    notifyListeners();
  }

  void stop() {
    _isProcessing = false;
    _message = '';
    _logs.clear();
    notifyListeners();
  }
}
