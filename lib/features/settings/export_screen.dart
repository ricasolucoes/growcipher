import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  static const String route = '/export';

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  final _passwordController = TextEditingController();
  bool _isExporting = false;

  Future<void> _export() async {
    final password = _passwordController.text;
    if (password.isEmpty) return;

    setState(() => _isExporting = true);

    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.createExport(password);

      if (mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'GrowCipher Backup');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar Backup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Os dados serão exportados em um arquivo ZIP criptografado com AES-256.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha para criptografia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isExporting ? null : _export,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock),
              label: Text(_isExporting ? 'Exportando...' : 'Exportar'),
            ),
          ],
        ),
      ),
    );
  }
}
