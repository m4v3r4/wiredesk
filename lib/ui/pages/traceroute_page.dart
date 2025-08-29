import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/providers/traceroute_provider.dart';

class TraceroutePage extends StatefulWidget {
  const TraceroutePage({super.key});

  @override
  State<TraceroutePage> createState() => _TraceroutePageState();
}

class _TraceroutePageState extends State<TraceroutePage> {
  final TextEditingController _controller = TextEditingController(
    text: '8.8.8.8',
  );
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Traceroute Tool')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Host / IP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<TracerouteProvider>(
                  builder: (context, tracerouteProvider, _) => ElevatedButton(
                    onPressed: tracerouteProvider.isTracing
                        ? null
                        : () async {
                            final host = _controller.text.trim();
                            await Provider.of<TracerouteProvider>(
                              context,
                              listen: false,
                            ).startTrace(host);

                            // İşlem bittiğinde otomatik scroll
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent,
                              );
                            }
                          },
                    child: Text(
                      tracerouteProvider.isTracing ? 'Tracing...' : 'Start',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<TracerouteProvider>(
              builder: (context, tracerouteProvider, _) {
                return tracerouteProvider.isTracing
                    ? const LinearProgressIndicator()
                    : const SizedBox(height: 4);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<TracerouteProvider>(
                builder: (context, tracerouteProvider, _) {
                  final lines = tracerouteProvider.lines;
                  if (lines.isEmpty) {
                    return const Center(child: Text('Henüz sonuç yok.'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final line = lines[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.arrow_right_alt),
                            title: Text(line),
                          ),
                        ),
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
