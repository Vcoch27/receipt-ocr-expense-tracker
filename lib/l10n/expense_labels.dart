import 'package:flutter/widgets.dart';

import '../models/expense_source.dart';
import 'l10n.dart';

String localizedSource(BuildContext context, ExpenseSource source) =>
    switch (source) {
      ExpenseSource.receipt => context.l10n.receipt,
      ExpenseSource.bankScreenshot => context.l10n.bankTransfer,
      ExpenseSource.eWalletScreenshot => context.l10n.eWallet,
      ExpenseSource.manual => context.l10n.manual,
    };

String localizedStatus(BuildContext context, PaymentStatus status) =>
    switch (status) {
      PaymentStatus.successful => context.l10n.successful,
      PaymentStatus.pending => context.l10n.pending,
      PaymentStatus.failed => context.l10n.failed,
      PaymentStatus.unknown => context.l10n.needsVerification,
    };

String localizedCategory(BuildContext context, String category) =>
    switch (category) {
      'Food & drink' => context.l10n.foodDrink,
      'Transport' => context.l10n.transport,
      'Shopping' => context.l10n.shopping,
      'Study' => context.l10n.study,
      _ => context.l10n.other,
    };
