import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fcm_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FCMService _fcm;

  @override
  void initState() {
    super.initState();
    _fcm = FCMService();
    _fcm.initialize();
  }

  @override
  void dispose() {
    _fcm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Courier')),
      body: ListenableBuilder(
        listenable: _fcm,
        builder: (context, _) {
          final scheme = Theme.of(context).colorScheme;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(_fcm.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(_fcm.assetPath, fit: BoxFit.cover, height: 180),
              ),
              const SizedBox(height: 4),
              Text('Current asset: ${_fcm.assetKey}'),
              const SizedBox(height: 16),
              Card(
                color: _fcm.lastWasValid
                    ? scheme.primaryContainer
                    : scheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last handler: ${_fcm.lastHandler}'),
                      Text('Receipts this launch: ${_fcm.receiptCount}'),
                      Text('Message ID: ${_fcm.messageId}'),
                      const SizedBox(height: 8),
                      Text('Diagnostic: ${_fcm.diagnostic}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Permission: ${_fcm.permission}'),
              const SizedBox(height: 8),
              const Text('FCM token (redact in screenshots!):'),
              SelectableText(_fcm.token ?? 'no token yet'),
              TextButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy token'),
                onPressed: _fcm.token == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: _fcm.token!));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Token copied')));
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}
