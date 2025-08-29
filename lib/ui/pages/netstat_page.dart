import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/helpers/process_helper.dart';
import 'package:wiredesk/providers/netstat_provider.dart';

class NetstatPage extends StatelessWidget {
  const NetstatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Netstat / Connections')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Consumer<NetstatProvider>(
              builder: (context, netstatProvider, child) {
                return ElevatedButton(
                  onPressed: () async {
                    await runWithProcess(
                      context,
                      message: 'Mevcut Bağlantılar Taranıyor...',
                      action: (process) async {
                        process.addLog('Tarama başlatıldı');

                        // Örnek: 4 kez fetch, istersen tek sefer de yapabilirsin
                        for (var i = 1; i <= 4; i++) {
                          await netstatProvider.fetchConnections();
                          process.addLog(
                            'Yenileme $i tamamlandı: ${netstatProvider.connections.length} bağlantı bulundu',
                          );
                        }

                        process.addLog('Tarama tamamlandı');
                      },
                    );
                  },
                  child: const Text('Refresh Connections'),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<NetstatProvider>(
              builder: (context, netstatProvider, child) {
                return netstatProvider.isLoading
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<NetstatProvider>(
                builder: (context, netstatProvider, child) {
                  if (netstatProvider.connections.isEmpty) {
                    return const Center(child: Text('Bağlantı bulunamadı.'));
                  }
                  return ListView.builder(
                    itemCount: netstatProvider.connections.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.link),
                        title: Text(netstatProvider.connections[index]),
                      );
                    },
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
