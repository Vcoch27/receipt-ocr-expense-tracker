enum ExpenseSource {
  receipt,
  bankScreenshot,
  eWalletScreenshot,
  manual;

  String get label => switch (this) {
    receipt => 'Receipt',
    bankScreenshot => 'Bank transfer',
    eWalletScreenshot => 'E-wallet',
    manual => 'Manual',
  };
}

enum PaymentStatus {
  successful,
  pending,
  failed,
  unknown;

  String get label => switch (this) {
    successful => 'Successful',
    pending => 'Pending',
    failed => 'Failed',
    unknown => 'Needs verification',
  };
}
