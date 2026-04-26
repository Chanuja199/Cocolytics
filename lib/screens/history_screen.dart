import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/app_colors.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<ScanProvider>().loadScanHistory(auth.currentUser?.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final auth = context.watch<AuthProvider>();
    final loc = context.watch<LocalizationProvider>();
    final history = scanProvider.scanHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('history')),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: history.isEmpty
          ? Center(
              child: Text(loc.translate('recent_scans') + '...'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final scan = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: scan.imageUrl.startsWith('http')
                          ? Image.network(scan.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : Image.file(File(scan.imageUrl), width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(loc.translate(scan.diseaseName) != scan.diseaseName ? loc.translate(scan.diseaseName) : scan.diseaseName),
                    subtitle: Text('${(scan.confidence * 100).toStringAsFixed(1)}% ${loc.translate('confidence')}'),
                    onTap: () {
                      context.read<ScanProvider>().setCurrentScan(scan);
                      context.push('/result');
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteScan(context, scan.id, auth.currentUser?.id ?? '', loc),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _deleteScan(BuildContext context, String scanId, String userId, LocalizationProvider loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('delete')),
        content: Text(loc.translate('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.translate('cancel'))),
          TextButton(
            onPressed: () {
              context.read<ScanProvider>().deleteScan(scanId, userId);
              Navigator.pop(ctx);
            },
            child: Text(loc.translate('yes'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
