import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/helpers/process_helper.dart';
import 'package:wiredesk/providers/ssl_provider.dart';

class SSLPage extends StatefulWidget {
  const SSLPage({super.key});

  @override
  State<SSLPage> createState() => _SSLPageState();
}

class _SSLPageState extends State<SSLPage> {
  final TextEditingController _hostController = TextEditingController(
    text: 'google.com',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSL/TLS Checker')),
      body: Padding(
        padding: const EdgeInsets.all(12),
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
            Consumer<SslProvider>(
              builder: (context, sslProvider, child) {
                return ElevatedButton(
                  onPressed: () async {
                    final host = _hostController.text.trim();

                    await runWithProcess(
                      context,
                      message: '$host SSL/TLS Kontrolü Yapılıyor',
                      action: (process) async {
                        process.addLog('SSL kontrol başlatıldı: $host');
                        await sslProvider.check(host);
                        process.addLog(
                          'Kontrol tamamlandı: \n${sslProvider.result}',
                        );
                      },
                    );
                  },
                  child: const Text('Check SSL'),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<SslProvider>(
              builder: (context, sslProvider, child) {
                return sslProvider.isChecking
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<SslProvider>(
                builder: (context, sslProvider, child) {
                  if (sslProvider.result.isEmpty) {
                    return const Center(child: Text('Henüz sonuç yok.'));
                  }
                  return SingleChildScrollView(
                    child: SelectableText(sslProvider.result),
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
