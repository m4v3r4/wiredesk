import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/helpers/process_helper.dart';
import 'package:wiredesk/providers/dns_provider.dart';

class DNSPage extends StatefulWidget {
  const DNSPage({super.key});

  @override
  State<DNSPage> createState() => _DNSPageState();
}

class _DNSPageState extends State<DNSPage> {
  final TextEditingController _hostController = TextEditingController(
    text: 'google.com',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DNS Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Consumer<DnsProvider>(
              builder: (context, dnsProvider, child) {
                return ElevatedButton(
                  onPressed: () async {
                    await runWithProcess(
                      context,
                      message: 'DNS Taranıyor...',
                      action: (process) async {
                        final host = _hostController.text.trim();
                        process.addLog('Başlatıldı: $host');

                        // Örnek olarak 4 kez lookup (gerektiğinde tek sefer de olabilir)
                        for (var i = 1; i <= 4; i++) {
                          await dnsProvider.lookup(host);
                          process.addLog(
                            'Lookup $i tamamlandı: ${dnsProvider.records.join(', ')}',
                          );
                        }

                        process.addLog('DNS tarama tamamlandı.');
                      },
                    );
                  },
                  child: const Text('Lookup'),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<DnsProvider>(
              builder: (context, dnsProvider, child) {
                return dnsProvider.isLookingUp
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<DnsProvider>(
                builder: (context, dnsProvider, child) {
                  if (dnsProvider.records.isEmpty) {
                    return const Center(child: Text('Kayıt bulunamadı.'));
                  }
                  return ListView.builder(
                    itemCount: dnsProvider.records.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.dns),
                        title: Text(dnsProvider.records[index]),
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
