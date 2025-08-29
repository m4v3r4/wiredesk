import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/providers/subnet_provider.dart';

class SubnetPage extends StatefulWidget {
  const SubnetPage({super.key});

  @override
  State<SubnetPage> createState() => _SubnetPageState();
}

class _SubnetPageState extends State<SubnetPage> {
  final TextEditingController _controller = TextEditingController(
    text: '192.168.1.0/24',
  );

  @override
  Widget build(BuildContext context) {
    final subnetProvider = Provider.of<SubnetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Subnet Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'IP / Prefix (e.g. 192.168.1.0/24)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                subnetProvider.calculate(_controller.text.trim());
              },
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  subnetProvider.result,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
