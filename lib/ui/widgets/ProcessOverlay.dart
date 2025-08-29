import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/providers/ProcessProvider.dart';

class ProcessOverlay extends StatelessWidget {
  const ProcessOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProcessProvider>(
      builder: (context, process, child) {
        if (!process.isProcessing) return const SizedBox.shrink();

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150, // overlay yüksekliği
          child: Container(
            color: Colors.black.withOpacity(0.8),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        process.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => process.stop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: process.logs
                          .map(
                            (log) => Text(
                              log,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
