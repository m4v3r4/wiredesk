import 'package:flutter/material.dart';
import 'package:wiredesk/ui/pages/DeviceHuntPage.dart';
import 'package:wiredesk/ui/pages/dns_page.dart';
import 'package:wiredesk/ui/pages/port_scanner_page.dart';
import 'package:wiredesk/ui/pages/wol_page.dart';
import 'package:wiredesk/ui/pages/whois_page.dart';
import 'package:wiredesk/ui/pages/ssl_page.dart';
import 'package:wiredesk/ui/pages/netstat_page.dart';
import 'package:wiredesk/ui/pages/speed_page.dart';
import 'package:wiredesk/ui/pages/subnet_page.dart';
import 'package:wiredesk/ui/widgets/ProcessOverlay.dart';
import 'pages/ping_page.dart';
import 'pages/traceroute_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {
        'title': 'Ping Tool',
        'icon': Icons.network_ping,
        'page': const PingPage(),
      },
      {
        'title': 'Traceroute Tool',
        'icon': Icons.alt_route,
        'page': const TraceroutePage(),
      },
      {
        'title': 'Port Scanner',
        'icon': Icons.wifi_tethering,
        'page': const PortScannerPage(),
      },
      {'title': 'DNS Lookup', 'icon': Icons.dns, 'page': const DNSPage()},
      {'title': 'Wake-on-LAN', 'icon': Icons.power, 'page': const WOLPage()},
      {'title': 'Whois Lookup', 'icon': Icons.info, 'page': const WhoisPage()},
      {
        'title': 'SSL/TLS Checker',
        'icon': Icons.security,
        'page': const SSLPage(),
      },
      {
        'title': 'Netstat / Connections',
        'icon': Icons.network_check,
        'page': const NetstatPage(),
      },
      {
        'title': 'Network Speed Test',
        'icon': Icons.speed,
        'page': const SpeedPage(),
      },
      {
        'title': 'DeviceHunt',
        'icon': Icons.devices_other,
        'page': const NetworkScannerPage(),
      },
      {
        'title': 'Subnet Calculator',
        'icon': Icons.device_hub,
        'page': const SubnetPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('WireDesk')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: tools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final tool = tools[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => tool['page'] as Widget,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tool['icon'] as IconData,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tool['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Positioned(bottom: 0, right: 0, child: Text("V1.0")),
          const ProcessOverlay(),
        ],
      ),
    );
  }
}
