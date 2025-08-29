import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredesk/providers/NetworkScannerProvider.dart';
import 'package:wiredesk/providers/ProcessProvider.dart';
import 'package:wiredesk/providers/dns_provider.dart';
import 'package:wiredesk/providers/netstat_provider.dart';
import 'package:wiredesk/providers/port_scanner_provider.dart';
import 'package:wiredesk/providers/speed_provider.dart';
import 'package:wiredesk/providers/ssl_provider.dart';
import 'package:wiredesk/providers/subnet_provider.dart';
import 'package:wiredesk/providers/whois_provider.dart';
import 'package:wiredesk/providers/wol_provider.dart';
import 'package:wiredesk/ui/HomePage.dart';
import 'providers/ping_provider.dart';
import 'providers/traceroute_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PingProvider()),
        ChangeNotifierProvider(create: (_) => TracerouteProvider()),
        ChangeNotifierProvider(create: (_) => PortScannerProvider()),
        ChangeNotifierProvider(create: (_) => DnsProvider()),
        ChangeNotifierProvider(create: (_) => WolProvider()),
        ChangeNotifierProvider(create: (_) => WhoisProvider()),
        ChangeNotifierProvider(create: (_) => SslProvider()),
        ChangeNotifierProvider(create: (_) => NetstatProvider()),
        ChangeNotifierProvider(create: (_) => SpeedProvider()),
        ChangeNotifierProvider(create: (_) => SubnetProvider()),
        ChangeNotifierProvider(create: (_) => NetworkScannerProvider()),

        ChangeNotifierProvider(
          create: (_) => ProcessProvider(),
        ), // <--- ekledik
      ],
      child: const NetToolkitApp(),
    ),
  );
}

class NetToolkitApp extends StatelessWidget {
  const NetToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WireDesk',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}
