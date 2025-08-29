import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/helpers/process_helper.dart';
import 'package:wiredesk/providers/port_scanner_provider.dart';
import 'package:wiredesk/ui/pages/ScanResultPage.dart';

class PortScannerPage extends StatefulWidget {
  const PortScannerPage({super.key});

  @override
  State<PortScannerPage> createState() => _PortScannerPageState();
}

class _PortScannerPageState extends State<PortScannerPage> {
  final TextEditingController _hostController = TextEditingController(
    text: '127.0.0.1',
  );
  final TextEditingController _startPortController = TextEditingController(
    text: '1',
  );
  final TextEditingController _endPortController = TextEditingController(
    text: '1024',
  );
  final TextEditingController _filterController = TextEditingController();
  bool _serviceVersionScan = false; // Nmap tarzı versiyon taraması

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Port Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host / IP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startPortController,
                    decoration: const InputDecoration(
                      labelText: 'Start Port',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endPortController,
                    decoration: const InputDecoration(
                      labelText: 'End Port',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _filterController,
              decoration: const InputDecoration(
                labelText: 'Filtre (örn: 22,80,443)',
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              value: _serviceVersionScan,
              onChanged: (v) =>
                  setState(() => _serviceVersionScan = v ?? false),
              title: const Text('Servis ve versiyon taraması yap'),
            ),
            const SizedBox(height: 12),
            Consumer<PortScannerProvider>(
              builder: (context, portProvider, child) {
                return ElevatedButton(
                  onPressed: portProvider.isScanning
                      ? null
                      : () async {
                          final host = _hostController.text.trim();
                          final start =
                              int.tryParse(_startPortController.text.trim()) ??
                              1;
                          final end =
                              int.tryParse(_endPortController.text.trim()) ??
                              1024;
                          final filter = _filterController.text.trim();

                          await runWithProcess(
                            context,
                            message: '$host Port Taranıyor',
                            action: (process) async {
                              process.addLog(
                                'Tarama başlatıldı: $host, port $start-$end',
                              );

                              await portProvider.startScan(
                                host,
                                start,
                                end,
                                serviceVersionScan: _serviceVersionScan,
                                onPortFound: (port, isOpen, service, banner) {
                                  if (filter.isEmpty ||
                                      filter
                                          .split(',')
                                          .contains(port.toString())) {
                                    process.addLog(
                                      'Port $port: Açık ($service) ${banner.isNotEmpty ? "| Banner: $banner" : ""}',
                                    );
                                  }
                                },
                              );

                              if (portProvider.openPorts.isEmpty) {
                                process.addLog('Hiç açık port bulunamadı.');
                              }
                              process.addLog('Port tarama tamamlandı.');
                              if (!portProvider.isScanning) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScanReportPage(
                                      host: _hostController.text.trim(),
                                      portDetails: portProvider.portDetails,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                  child: Text(
                    portProvider.isScanning ? 'Taranıyor...' : 'Start Scan',
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<PortScannerProvider>(
              builder: (context, portProvider, child) {
                return portProvider.isScanning
                    ? LinearProgressIndicator(value: portProvider.progress)
                    : const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<PortScannerProvider>(
                builder: (context, portProvider, child) {
                  if (portProvider.scanLogs.isEmpty) {
                    return const Center(
                      child: Text('Tarama logları burada gösterilecek.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: portProvider.scanLogs.length,
                    itemBuilder: (context, index) {
                      final log = portProvider.scanLogs[index];
                      bool isOpen =
                          log.contains('Açık port') || log.contains('Açık');
                      String banner = '';
                      RegExp bannerRegex = RegExp(r'Banner: (.*)');
                      final match = bannerRegex.firstMatch(log);
                      if (match != null) banner = match.group(1) ?? '';

                      return ListTile(
                        leading: Icon(
                          isOpen ? Icons.check_circle : Icons.cancel,
                          color: isOpen ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          log,
                          style: TextStyle(
                            fontWeight: isOpen
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: isOpen && banner.isNotEmpty
                            ? Text('Detay: $banner')
                            : null,
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
