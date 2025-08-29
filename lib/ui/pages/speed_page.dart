import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/helpers/process_helper.dart';
import 'package:wiredesk/providers/speed_provider.dart';

class SpeedPage extends StatelessWidget {
  const SpeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Speed Test')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Consumer<SpeedProvider>(
          builder: (context, speedProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await runWithProcess(
                      context,
                      message: 'Hız Testi Yapılıyor...',
                      action: (process) async {
                        // Örnek olarak 4 defa test
                        for (var i = 1; i <= 4; i++) {
                          await speedProvider.testSpeed();
                          process.addLog(
                            'Test $i: Download ${speedProvider.downloadMbps.toStringAsFixed(2)} Mbps',
                          );
                        }
                      },
                    );
                  },
                  child: const Text('Start Test'),
                ),
                const SizedBox(height: 12),
                if (speedProvider.isTesting) const LinearProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Download: ${speedProvider.downloadMbps.toStringAsFixed(2)} Mbps',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Upload: ${speedProvider.uploadMbps.toStringAsFixed(2)} Mbps (not implemented)',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
