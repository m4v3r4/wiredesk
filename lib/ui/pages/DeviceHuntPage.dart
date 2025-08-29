import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/providers/NetworkScannerProvider.dart';

class NetworkScannerPage extends StatefulWidget {
  const NetworkScannerPage({super.key});

  @override
  State<NetworkScannerPage> createState() => _NetworkScannerPageState();
}

class _NetworkScannerPageState extends State<NetworkScannerPage> {
  final TextEditingController baseIpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setBaseIp();
  }

  Future<void> _setBaseIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        final ip = interfaces.first.addresses.first.address;
        final parts = ip.split('.');
        if (parts.length == 4) {
          final baseIp = '${parts[0]}.${parts[1]}.${parts[2]}';
          setState(() {
            baseIpController.text = baseIp;
          });
        }
      }
    } catch (e) {
      baseIpController.text = '192.168.1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DeviceHunt')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Sol panel: canlı cihaz listesi ve tarama başlatma
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: baseIpController,
                    decoration: const InputDecoration(
                      labelText: 'Base IP (e.g. 192.168.1)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<NetworkScannerProvider>(
                    builder: (context, scanner, _) => ElevatedButton(
                      onPressed: scanner.isScanning
                          ? null
                          : () => scanner.scanNetwork(
                              baseIpController.text.trim(),
                            ),
                      child: Text(scanner.isScanning ? 'Scanning...' : 'Scan'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Live Devices:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Consumer<NetworkScannerProvider>(
                      builder: (context, scanner, _) {
                        final devices = scanner.devices
                            .where((d) => d.isAlive)
                            .toList();
                        if (devices.isEmpty) {
                          return const Center(
                            child: Text('No live devices yet.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final d = devices[index];
                            return ListTile(
                              leading: Icon(
                                Icons.device_hub,
                                color: Colors.green,
                              ),
                              title: Text(d.ip),
                              subtitle: Text(
                                'MAC: ${d.mac ?? 'Unknown'} | OS: ${d.osGuess ?? '-'}',
                              ),
                              onTap: () {
                                // Cihaz tıklanınca sağ panelde detayları göster
                                // State yönetimi sağ panelde otomatik güncellenir
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            // Sağ panel: istatistikler ve detaylı cihaz bilgileri
            Expanded(
              flex: 2,
              child: Consumer<NetworkScannerProvider>(
                builder: (context, scanner, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total IPs scanned: ${scanner.totalIPs}'),
                    Text('Alive: ${scanner.aliveCount}'),
                    Text('Dead: ${scanner.deadCount}'),
                    Text('Avg Ping: ${scanner.avgPing.toStringAsFixed(1)} ms'),
                    const SizedBox(height: 12),
                    const Text(
                      'All Devices',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: scanner.devices.length,
                        itemBuilder: (context, index) {
                          final d = scanner.devices[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                Icons.network_ping,
                                color: d.isAlive ? Colors.green : Colors.grey,
                              ),
                              title: Text(d.ip),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('MAC: ${d.mac ?? 'Unknown'}'),
                                  Text('Ping: ${d.pingTime ?? '-'} ms'),
                                  Text('Alive: ${d.isAlive ? 'Yes' : 'No'}'),
                                  Text('OS: ${d.osGuess ?? '-'}'),
                                  Text(
                                    'Open Ports: ${d.openPorts.isNotEmpty ? d.openPorts.join(', ') : '-'}',
                                  ),
                                  if (d.portBanners.isNotEmpty)
                                    Text(
                                      'Banners: ${d.portBanners.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
