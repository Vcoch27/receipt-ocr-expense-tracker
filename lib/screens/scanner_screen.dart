import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../models/parsed_expense.dart';
import '../l10n/l10n.dart';
import '../routing/app_router.dart';
import '../state/expense_providers.dart';
import '../widgets/page_container.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _start(Future<ParsedExpense?> Function() capture) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await capture();
      if (!mounted) return;
      if (result != null) {
        context.push('/review', extra: ReviewArgs(draft: result));
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _error = context.l10n.ocrTimeout);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.ocrError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(receiptScanServiceProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addExpense)),
      body: SafeArea(
        child: PageContainer(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                context.l10n.chooseSource,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.localPrivacyHint,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _SourceCard(
                icon: Icons.phone_android_outlined,
                title: context.l10n.importPaymentScreenshot,
                subtitle: context.l10n.paymentSourceHint,
                prominent: true,
                onTap: _busy
                    ? null
                    : () => _start(service.importPaymentScreenshot),
              ),
              const SizedBox(height: 12),
              _SourceCard(
                icon: Icons.document_scanner_outlined,
                title: context.l10n.scanReceipt,
                subtitle: context.l10n.scanReceiptHint,
                onTap: _busy
                    ? null
                    : () => _start(
                        () => service.captureReceipt(ImageSource.camera),
                      ),
              ),
              const SizedBox(height: 12),
              _SourceCard(
                icon: Icons.photo_library_outlined,
                title: context.l10n.chooseReceiptPhoto,
                subtitle: context.l10n.chooseReceiptPhotoHint,
                onTap: _busy
                    ? null
                    : () => _start(
                        () => service.captureReceipt(ImageSource.gallery),
                      ),
              ),
              const SizedBox(height: 12),
              _SourceCard(
                icon: Icons.edit_note_outlined,
                title: context.l10n.manualEntry,
                subtitle: context.l10n.manualEntryHint,
                onTap: _busy
                    ? null
                    : () => context.push(
                        '/review',
                        extra: const ReviewArgs(draft: ParsedExpense.manual()),
                      ),
              ),
              if (_busy) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 8),
                Center(child: Text(context.l10n.readingImage)),
              ],
              if (_error != null) ...[
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.prominent = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: prominent ? scheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 30, color: scheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
