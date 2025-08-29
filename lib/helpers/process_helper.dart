import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ProcessProvider.dart';

/// Herhangi bir async işlemi process overlay ile çalıştırır
Future<T> runWithProcess<T>(
  BuildContext context, {
  required String message,
  required Future<T> Function(ProcessProvider process) action,
}) async {
  final process = Provider.of<ProcessProvider>(context, listen: false);
  process.start(message);

  try {
    return await action(
      process,
    ); // burada log eklemek için process.addLog kullanabilirsin
  } catch (e) {
    process.addLog('Hata: $e');
    rethrow;
  } finally {
    process.stop();
  }
}
