import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/categories.dart';
import '../core/expense_validation.dart';
import '../core/formatters.dart';
import '../l10n/expense_labels.dart';
import '../l10n/l10n.dart';
import '../models/expense_item.dart';
import '../models/expense_source.dart';
import '../models/parsed_expense.dart';
import '../routing/app_router.dart';
import '../services/ai_receipt_service.dart';
import '../state/expense_providers.dart';
import '../widgets/page_container.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.args});
  final ReviewArgs args;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchant = TextEditingController();
  final _amount = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _provider = TextEditingController();
  final _reference = TextEditingController();
  final _note = TextEditingController();
  final _amountFocus = FocusNode();
  String _category = categories.last;
  PaymentStatus? _status;
  bool _saving = false;
  bool _readingWithAi = false;
  String? _aiError;
  String? _saveError;

  ParsedExpense get _draft => widget.args.draft ?? const ParsedExpense.manual();
  ExpenseItem? get _existing => widget.args.existing;
  ExpenseSource get _source => _existing?.source ?? _draft.source;
  bool get _isPayment =>
      _source == ExpenseSource.bankScreenshot ||
      _source == ExpenseSource.eWalletScreenshot;

  @override
  void initState() {
    super.initState();
    final old = _existing;
    final draft = _draft;
    _merchant.text = old?.merchant ?? draft.merchant ?? '';
    _amount.text = (old?.amount ?? draft.amount)?.toString() ?? '';
    final date = old?.date ?? draft.date;
    if (date != null) {
      _date.text = formatDate(date);
      if (date.hour != 0 || date.minute != 0) {
        _time.text =
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    }
    _provider.text = old?.paymentProvider ?? draft.paymentProvider ?? '';
    _reference.text =
        old?.transactionReference ?? draft.transactionReference ?? '';
    _note.text = old?.note ?? draft.note ?? '';
    _category = old?.category ?? categories.last;
    _status = old?.status ?? draft.status;
  }

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    _date.dispose();
    _time.dispose();
    _provider.dispose();
    _reference.dispose();
    _note.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = ExpenseValidation.dateTime(_date.text) ?? DateTime.now();
    final chosen = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (chosen != null) _date.text = formatDate(chosen);
  }

  Future<void> _readWithAi() async {
    if (_readingWithAi || _saving) return;
    final consent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.aiConsentTitle),
        content: Text(context.l10n.aiConsentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.aiSendImage),
          ),
        ],
      ),
    );
    if (consent != true || !mounted) return;
    setState(() {
      _readingWithAi = true;
      _aiError = null;
    });
    try {
      final suggestion = await ref
          .read(aiReceiptServiceProvider)
          .suggest(_draft);
      if (!mounted) return;
      if (suggestion.isEmpty) {
        setState(() => _aiError = context.l10n.aiNoSuggestion);
        return;
      }
      final apply = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.aiSuggestionTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.aiSuggestionHint),
                const SizedBox(height: 16),
                if (suggestion.merchant != null)
                  Text('${context.l10n.merchant}: ${suggestion.merchant}'),
                if (suggestion.amount != null)
                  Text(
                    '${context.l10n.amountVnd}: ${formatVnd(suggestion.amount!)}',
                  ),
                if (suggestion.date != null)
                  Text(
                    '${context.l10n.transactionDate}: ${formatDate(suggestion.date!)}',
                  ),
                if (suggestion.note != null)
                  Text('${context.l10n.note}: ${suggestion.note}'),
                if (_isPayment && suggestion.transactionReference != null)
                  Text(
                    '${context.l10n.reference}: ${suggestion.transactionReference}',
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.aiApplySuggestion),
            ),
          ],
        ),
      );
      if (apply == true && mounted) {
        _applyAiSuggestion(suggestion);
      }
    } catch (_) {
      if (mounted) setState(() => _aiError = context.l10n.aiReadError);
    } finally {
      if (mounted) setState(() => _readingWithAi = false);
    }
  }

  void _applyAiSuggestion(AiExpenseSuggestion suggestion) {
    setState(() {
      if (suggestion.merchant != null) {
        _merchant.text = suggestion.merchant!;
      }
      if (suggestion.amount != null) {
        _amount.text = suggestion.amount.toString();
      }
      if (suggestion.date != null) {
        _date.text = formatDate(suggestion.date!);
        if (_isPayment) {
          _time.clear();
        }
      }
      if (suggestion.note != null) {
        _note.text = suggestion.note!;
      }
      if (_isPayment && suggestion.transactionReference != null) {
        _reference.text = suggestion.transactionReference!;
      }
    });
  }

  ExpenseItem _itemFromForm() {
    final old = _existing;
    final now = DateTime.now();
    return ExpenseItem(
      id: old?.id,
      merchant: _merchant.text.trim(),
      amount: ExpenseValidation.amount(_amount.text)!,
      date: ExpenseValidation.dateTime(
        _date.text,
        _isPayment ? _time.text : null,
      )!,
      category: _category,
      source: _source,
      status: _isPayment ? _status : null,
      paymentProvider: _isPayment && _provider.text.trim().isNotEmpty
          ? _provider.text.trim()
          : null,
      transactionReference: _isPayment && _reference.text.trim().isNotEmpty
          ? _reference.text.trim()
          : null,
      note: _note.text.trim().isNotEmpty ? _note.text.trim() : null,
      imagePath: old?.imagePath ?? _draft.imagePath,
      // Payment OCR may contain account numbers. Keep it in memory for
      // verification, then omit it from persistent records.
      rawOcrText: _isPayment ? null : old?.rawOcrText ?? _draft.rawText,
      createdAt: old?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final item = _itemFromForm();
    final existingItems = ref.read(expensesProvider).valueOrNull ?? [];
    final duplicate = ref
        .read(duplicateMatcherProvider)
        .find(item, existingItems);
    if (duplicate != null) {
      final saveAnyway = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.possibleDuplicate),
          content: Text(
            context.l10n.duplicateMessage(
              localizedSource(context, duplicate.source).toLowerCase(),
              duplicate.merchant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.reviewAgain),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.saveAnyway),
            ),
          ],
        ),
      );
      if (saveAnyway != true || !mounted) return;
    }
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      if (_existing == null) {
        await ref.read(expensesProvider.notifier).save(item);
      } else {
        await ref.read(expensesProvider.notifier).updateExpense(item);
      }
      if (!mounted) return;
      context.go('/expenses');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _existing == null
                ? context.l10n.expenseSaved
                : context.l10n.expenseUpdated,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _saveError = context.l10n.couldNotSave);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final draft = _draft;
    final image = _existing?.imagePath ?? draft.imagePath;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existing == null
              ? context.l10n.reviewVerify
              : context.l10n.editExpense,
        ),
      ),
      body: SafeArea(
        child: PageContainer(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: const Icon(Icons.verified_user_outlined, size: 18),
                    label: Text(localizedSource(context, _source)),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _existing == null
                      ? context.l10n.reviewHeadline
                      : context.l10n.editHeadline,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 14),
                Card(
                  color: theme.colorScheme.tertiaryContainer.withValues(
                    alpha: .55,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.l10n.reviewHint,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (image != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: theme.colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(image),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => ListTile(
                            leading: const Icon(Icons.broken_image_outlined),
                            title: Text(context.l10n.imagePreviewUnavailable),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (_existing == null &&
                    image != null &&
                    ref.read(aiReceiptServiceProvider).isAvailable) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const ValueKey('read_with_ai'),
                    onPressed: _readingWithAi ? null : _readWithAi,
                    icon: _readingWithAi
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_outlined),
                    label: Text(
                      _readingWithAi
                          ? context.l10n.aiReading
                          : context.l10n.aiReadAgain,
                    ),
                  ),
                  if (_aiError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _aiError!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
                if (_existing == null &&
                    draft.rawText.trim().isEmpty &&
                    _source != ExpenseSource.manual) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: theme.colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(context.l10n.noOcrText),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  key: const ValueKey('merchant_field'),
                  controller: _merchant,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _amountFocus.requestFocus(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.storefront_outlined),
                    labelText: _isPayment
                        ? context.l10n.recipientOrMerchant
                        : context.l10n.merchant,
                    helperText: _merchant.text.isEmpty
                        ? context.l10n.notDetected
                        : null,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? context.l10n.merchantRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('amount_field'),
                  controller: _amount,
                  focusNode: _amountFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.payments_outlined),
                    labelText: context.l10n.amountVnd,
                    hintText: '150.000',
                    helperText: context.l10n.amountHint,
                  ),
                  validator: (value) =>
                      ExpenseValidation.amount(value ?? '') == null
                      ? context.l10n.amountRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('date_field'),
                  controller: _date,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.event_outlined),
                    labelText: context.l10n.transactionDate,
                    hintText: 'dd/MM/yyyy',
                    suffixIcon: IconButton(
                      tooltip: context.l10n.chooseDate,
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  validator: (value) =>
                      ExpenseValidation.dateTime(
                            value ?? '',
                            _isPayment ? _time.text : null,
                          ) ==
                          null
                      ? context.l10n.dateRequired
                      : null,
                ),
                if (_isPayment) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _time,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: context.l10n.timeOptional,
                      hintText: '14:30',
                    ),
                    validator: (value) =>
                        value != null &&
                            value.trim().isNotEmpty &&
                            ExpenseValidation.dateTime(_date.text, value) ==
                                null
                        ? context.l10n.timeInvalid
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PaymentStatus>(
                    initialValue: _status,
                    decoration: InputDecoration(
                      labelText: context.l10n.transactionStatus,
                      helperText: context.l10n.successfulOnly,
                    ),
                    items: PaymentStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(localizedStatus(context, status)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _status = value),
                    validator: (value) => value == PaymentStatus.successful
                        ? null
                        : context.l10n.verifySuccess,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _provider,
                    decoration: InputDecoration(
                      labelText: context.l10n.bankWalletOptional,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reference,
                    decoration: InputDecoration(
                      labelText: context.l10n.referenceOptional,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: context.l10n.category),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(localizedCategory(context, category)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _note,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.l10n.noteOptional,
                  ),
                ),
                if (draft.rawText.trim().isNotEmpty && _existing == null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ExpansionTile(
                      title: Text(context.l10n.viewRecognizedText),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SelectionArea(child: Text(draft.rawText)),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_saveError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _saveError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const ValueKey('confirm_save'),
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _saving
                        ? context.l10n.saving
                        : _existing == null
                        ? context.l10n.confirmSave
                        : context.l10n.saveChanges,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
