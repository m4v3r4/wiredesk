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
  double _progress = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.alt_route, size: 26),
            SizedBox(width: 8),
            Text('Traceroute Tool'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TracerouteProgress(progress: _progress),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Host / IP',
                      prefixIcon: const Icon(Icons.language),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<TracerouteProvider>(
                  builder: (context, tracerouteProvider, _) =>
                      ElevatedButton.icon(
                        icon: tracerouteProvider.isTracing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          tracerouteProvider.isTracing ? 'Tracing...' : 'Start',
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
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
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position
                                            .maxScrollExtent,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                  );
                                }
                              },
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<TracerouteProvider>(
                builder: (context, tracerouteProvider, _) {
                  final lines = tracerouteProvider.lines;
                  if (lines.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Henüz sonuç yok.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final line = lines[index];

                      // Hop numarasını renge dönüştürelim
                      final hopColor = Colors
                          .primaries[index % Colors.primaries.length]
                          .shade200;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Card(
                          color: hopColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: hopColor,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              line,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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

class TracerouteProgress extends StatefulWidget {
  final double progress; // 0.0 - 1.0 arası
  const TracerouteProgress({super.key, required this.progress});

  @override
  State<TracerouteProgress> createState() => _TracerouteProgressState();
}

class _TracerouteProgressState extends State<TracerouteProgress> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: widget.progress, // ilerleme durumu
          minHeight: 8,
          backgroundColor: Colors.grey[300],
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 8),
        Text(
          "${(widget.progress * 100).toStringAsFixed(0)}%",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
