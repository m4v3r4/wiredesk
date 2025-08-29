import 'package:flutter/material.dart';

class ScanReportPage extends StatelessWidget {
  final String host;
  final Map<int, Map<String, String>> portDetails;

  const ScanReportPage({
    super.key,
    required this.host,
    required this.portDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Report: $host')),
      body: portDetails.isEmpty
          ? const Center(child: Text('Hiç açık port bulunamadı.'))
          : ListView.builder(
              itemCount: portDetails.length,
              itemBuilder: (context, index) {
                final port = portDetails.keys.elementAt(index);
                final details = portDetails[port]!;
                return ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Port: $port | Servis: ${details['service']}'),
                  subtitle: details['banner']!.isNotEmpty
                      ? Text('Banner: ${details['banner']}')
                      : null,
                );
              },
            ),
    );
  }
}
