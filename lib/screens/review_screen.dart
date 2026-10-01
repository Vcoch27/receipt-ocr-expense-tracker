import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/categories.dart';
import '../core/expense_validation.dart';
import '../core/formatters.dart';
import '../models/expense_item.dart';
import '../models/expense_source.dart';
import '../models/parsed_expense.dart';
import '../routing/app_router.dart';
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
          title: const Text('Possible duplicate'),
          content: Text(
            'A similar ${duplicate.source.label.toLowerCase()} expense for ${duplicate.merchant} is already saved. Save this one too?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Review again'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save anyway'),
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
            _existing == null ? 'Expense saved' : 'Expense updated',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _saveError = 'Could not save expense: $error');
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
        title: Text(_existing == null ? 'Review & Verify' : 'Edit expense'),
      ),
      body: SafeArea(
        child: PageContainer(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(
                  _source.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _existing == null
                      ? 'Check every detail before saving'
                      : 'Update the saved details',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'OCR can misread amounts and names. Correct any field that is missing or wrong.',
                  style: theme.textTheme.bodyMedium,
                ),
                if (image != null) ...[
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(image),
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const ListTile(
                        leading: Icon(Icons.broken_image_outlined),
                        title: Text('Image preview unavailable'),
                      ),
                    ),
                  ),
                ],
                if (_existing == null &&
                    draft.rawText.trim().isEmpty &&
                    _source != ExpenseSource.manual) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: theme.colorScheme.tertiaryContainer,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No text was recognized. Enter the details from the image manually.',
                      ),
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
                    labelText: _isPayment
                        ? 'Recipient or merchant'
                        : 'Merchant',
                    helperText: _merchant.text.isEmpty
                        ? 'Not detected — enter this manually'
                        : null,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a merchant or recipient'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('amount_field'),
                  controller: _amount,
                  focusNode: _amountFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Amount (VND)',
                    hintText: '150.000',
                    helperText: 'Use digits or Vietnamese thousands separators',
                  ),
                  validator: (value) =>
                      ExpenseValidation.amount(value ?? '') == null
                      ? 'Enter a positive amount'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('date_field'),
                  controller: _date,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'Transaction date',
                    hintText: 'dd/MM/yyyy',
                    suffixIcon: IconButton(
                      tooltip: 'Choose date',
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
                      ? 'Enter a valid date (dd/MM/yyyy)'
                      : null,
                ),
                if (_isPayment) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _time,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Time (optional)',
                      hintText: '14:30',
                    ),
                    validator: (value) =>
                        value != null &&
                            value.trim().isNotEmpty &&
                            ExpenseValidation.dateTime(_date.text, value) ==
                                null
                        ? 'Use 24-hour time (HH:mm)'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PaymentStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Transaction status',
                      helperText:
                          'Only confirmed successful payments can be saved',
                    ),
                    items: PaymentStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _status = value),
                    validator: (value) => value == PaymentStatus.successful
                        ? null
                        : 'Verify that this payment succeeded',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _provider,
                    decoration: const InputDecoration(
                      labelText: 'Bank or wallet (optional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reference,
                    decoration: const InputDecoration(
                      labelText: 'Transaction reference (optional)',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
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
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                ),
                if (draft.rawText.trim().isNotEmpty && _existing == null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ExpansionTile(
                      title: const Text('View recognized text'),
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
                        ? 'Saving…'
                        : _existing == null
                        ? 'Confirm & save'
                        : 'Save changes',
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
