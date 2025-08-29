import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/helpers/process_helper.dart';
import 'package:wiredesk/providers/ping_provider.dart';

class PingPage extends StatefulWidget {
  const PingPage({super.key});

  @override
  State<PingPage> createState() => _PingPageState();
}

class _PingPageState extends State<PingPage> {
  final TextEditingController _hostController = TextEditingController(
    text: '1.1.1.1',
  );
  final TextEditingController _countController = TextEditingController(
    text: '4',
  );
  final TextEditingController _timeoutController = TextEditingController(
    text: '2',
  );
  final TextEditingController _intervalController = TextEditingController(
    text: '1',
  );
  final TextEditingController _sizeController = TextEditingController(
    text: '32',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ping Tool')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Host / IP
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host / IP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Ayarlar Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _countController,
                    decoration: const InputDecoration(
                      labelText: 'Ping Sayısı',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _timeoutController,
                    decoration: const InputDecoration(
                      labelText: 'Timeout (s)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Interval (s)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _sizeController,
                    decoration: const InputDecoration(
                      labelText: 'Paket Boyutu',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ping Başlat Butonu
            Consumer<PingProvider>(
              builder: (context, pingProvider, child) {
                return ElevatedButton(
                  onPressed: pingProvider.isPinging
                      ? null
                      : () async {
                          final host = _hostController.text.trim();
                          final count =
                              int.tryParse(_countController.text) ?? 4;
                          final timeout =
                              int.tryParse(_timeoutController.text) ?? 2;
                          final interval =
                              int.tryParse(_intervalController.text) ?? 1;
                          final size = int.tryParse(_sizeController.text) ?? 32;

                          // Listeyi temizle
                          pingProvider.clearResponses();

                          await runWithProcess(
                            context,
                            message: '$host Ping Gönderiliyor',
                            action: (process) async {
                              for (var i = 1; i <= count; i++) {
                                await pingProvider.startPing(
                                  host,
                                  count: 1,
                                  timeoutSeconds: timeout,
                                  clearPrevious: false,
                                );

                                if (pingProvider.responses.isNotEmpty) {
                                  final lastResponse =
                                      pingProvider.responses.last;
                                  process.addLog(
                                    'Ping $i: ${lastResponse.ip} - ${lastResponse.time?.inMilliseconds ?? 'Timeout'} ms | ttl: ${lastResponse.ttl}',
                                  );
                                } else {
                                  process.addLog(
                                    'Ping $i: Yanıt alınamadı (host geçersiz veya zaman aşımı)',
                                  );
                                }

                                await Future.delayed(
                                  Duration(seconds: interval),
                                );
                              }

                              process.addLog('Ping tamamlandı');
                            },
                          );
                        },
                  child: const Text('Ping Başlat'),
                );
              },
            ),
            const SizedBox(height: 12),

            // LinearProgressIndicator
            Consumer<PingProvider>(
              builder: (context, pingProvider, child) {
                return pingProvider.isPinging
                    ? LinearProgressIndicator(
                        value:
                            pingProvider.packetCount /
                            (int.tryParse(_countController.text) ?? 4),
                      )
                    : const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),

            // Ping sonuçları ve istatistik
            Expanded(
              child: Consumer<PingProvider>(
                builder: (context, pingProvider, child) {
                  if (pingProvider.responses.isEmpty) {
                    return const Center(child: Text('Henüz yanıt yok.'));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: pingProvider.responses.length,
                          itemBuilder: (context, index) {
                            final res = pingProvider.responses[index];
                            return ListTile(
                              leading: const Icon(Icons.network_ping),
                              title: Text(
                                'Ping Paket ${index + 1} - Reply from ${res.ip}',
                              ),
                              subtitle: Text(
                                'time: ${res.time?.inMilliseconds} ms | ttl: ${res.ttl} | boyut: ${res.size}',
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 60, // istatistik alanına sabit yükseklik
                        child: Column(
                          children: [
                            Text(
                              'Gönderilen: ${pingProvider.packetsSent}, Alınan: ${pingProvider.packetsReceived}, Kaybolan: ${pingProvider.packetsLost}, Paket kaybı: ${pingProvider.packetLossPercentage.toStringAsFixed(1)}%',
                            ),
                            Text(
                              'Min: ${pingProvider.minTime} ms, Max: ${pingProvider.maxTime} ms, Avg: ${pingProvider.avgTime.toStringAsFixed(1)} ms',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
