import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/backup_provider.dart';
import 'accounts_screen.dart';
import 'categories_screen.dart';

/// Preferências, cadastros e backup do aplicativo.
class ConfiguracoesScreen extends ConsumerStatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  ConsumerState<ConfiguracoesScreen> createState() =>
      _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends ConsumerState<ConfiguracoesScreen> {
  bool _busy = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Exporta todos os dados para um arquivo .json (backup completo).
  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      final content = await ref.read(backupRepositoryProvider).exportBackup();
      final now = DateTime.now();
      final suggested = 'centivo-backup-'
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}.json';
      final path = await ref
          .read(backupFileManagerProvider)
          .saveBackup(suggested, content);
      if (!mounted) return;
      if (path != null) {
        _showSnack('Backup salvo em $path');
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Erro ao exportar o backup.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Substitui todos os dados atuais pelos de um arquivo de backup.
  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar backup?'),
        content: const Text(
          'Todos os dados atuais serão substituídos pelos dados do arquivo '
          'de backup selecionado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final content = await ref.read(backupFileManagerProvider).readBackup();
      if (!mounted) return;
      if (content == null) return; // usuário cancelou a seleção
      await ref.read(backupRepositoryProvider).importBackup(content);
      if (!mounted) return;
      _showSnack('Backup restaurado com sucesso.');
    } on FormatException {
      if (!mounted) return;
      _showSnack('Arquivo inválido: não é um backup do Centivo.');
    } catch (_) {
      if (!mounted) return;
      _showSnack('Erro ao restaurar o backup.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset('assets/logo.png', height: 40),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.label_outline),
          title: const Text('Categorias'),
          subtitle: const Text('Ícones e cores das movimentações'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Contas'),
          subtitle: const Text('Contas financeiras do usuário'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AccountsScreen()),
            );
          },
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Backup',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Exportar backup'),
          subtitle: const Text('Salva todos os dados em um arquivo .json'),
          onTap: _busy ? null : _exportBackup,
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Restaurar backup'),
          subtitle: const Text('Substitui os dados atuais pelos do arquivo'),
          onTap: _busy ? null : _restoreBackup,
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(minHeight: 4),
          ),
      ],
    );
  }
}
