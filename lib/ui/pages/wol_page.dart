import 'package:flutter/material.dart';
import 'package:wiredesk/helpers/process_helper.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/providers/wol_provider.dart';

class WOLPage extends StatefulWidget {
  const WOLPage({super.key});

  @override
  State<WOLPage> createState() => _WOLPageState();
}

class _WOLPageState extends State<WOLPage> {
  final TextEditingController _macController = TextEditingController(
    text: '00:11:22:33:44:55',
  );
  final TextEditingController _broadcastController = TextEditingController(
    text: '192.168.1.255',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wake-on-LAN')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _macController,
              decoration: const InputDecoration(
                labelText: 'MAC Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _broadcastController,
              decoration: const InputDecoration(
                labelText: 'Broadcast IP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final mac = _macController.text.trim();
                final broadcast = _broadcastController.text.trim();

                await runWithProcess(
                  context,
                  message: 'WOL paketi gönderiliyor...',
                  action: (process) async {
                    process.addLog('MAC: $mac | Broadcast: $broadcast');

                    await Provider.of<WolProvider>(
                      context,
                      listen: false,
                    ).sendMagicPacket(mac, broadcast);

                    process.addLog('WOL paketi gönderildi');
                  },
                );
              },
              child: const Text('Send WOL Packet'),
            ),
            const SizedBox(height: 12),
            Consumer<WolProvider>(
              builder: (context, wolProvider, child) {
                return wolProvider.isSending
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
