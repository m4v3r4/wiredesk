import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/providers/whois_provider.dart';

class WhoisPage extends StatefulWidget {
  const WhoisPage({super.key});

  @override
  State<WhoisPage> createState() => _WhoisPageState();
}

class _WhoisPageState extends State<WhoisPage> {
  final TextEditingController _controller = TextEditingController(
    text: 'google.com',
  );

  @override
  Widget build(BuildContext context) {
    final whoisProvider = Provider.of<WhoisProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Whois Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Domain',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => whoisProvider.lookup(_controller.text.trim()),
              child: const Text('Lookup'),
            ),
            const SizedBox(height: 12),
            if (whoisProvider.isQuerying) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(whoisProvider.result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
