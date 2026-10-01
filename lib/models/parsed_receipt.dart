class ParsedReceipt {
  const ParsedReceipt({
    this.merchant,
    this.date,
    this.total,
    required this.rawText,
    this.imagePath,
  });

  final String? merchant;
  final DateTime? date;
  final int? total;
  final String rawText;
  final String? imagePath;
}
