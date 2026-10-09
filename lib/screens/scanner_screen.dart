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
import '../widgets/app_header.dart';

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
      appBar: AppHeader(subtitle: context.l10n.addExpense),
      body: SafeArea(
        child: PageContainer(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                context.l10n.threeStepFlow,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.chooseSource,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.captureSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Card(
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      _FlowStep(
                        number: '1',
                        label: context.l10n.stepPick,
                        selected: true,
                      ),
                      const Expanded(child: Divider()),
                      _FlowStep(number: '2', label: context.l10n.stepReview),
                      const Expanded(child: Divider()),
                      _FlowStep(number: '3', label: context.l10n.stepSave),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 18),
              Card(
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.localPrivacyHint,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      color: prominent ? scheme.primaryContainer.withValues(alpha: .55) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 23),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: prominent
                    ? scheme.secondaryContainer
                    : scheme.surfaceContainerHigh,
                child: Icon(icon, size: 27, color: scheme.primary),
              ),
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
              Icon(Icons.arrow_forward_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.number,
    required this.label,
    this.selected = false,
  });
  final String number;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: selected
              ? scheme.primary
              : scheme.surfaceContainerHigh,
          child: Text(
            number,
            style: TextStyle(
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
