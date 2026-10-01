import 'package:flutter/material.dart';

const categories = <String>[
  'Food & drink',
  'Transport',
  'Shopping',
  'Study',
  'Other',
];

Color categoryColor(String category) => switch (category) {
  'Food & drink' => const Color(0xFF176B8A),
  'Transport' => const Color(0xFF287A56),
  'Shopping' => const Color(0xFFBA761D),
  'Study' => const Color(0xFF7655A6),
  _ => const Color(0xFF6C747A),
};
