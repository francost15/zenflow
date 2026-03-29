import 'package:flutter/material.dart';

IconData courseIconForName(String courseName) {
  final normalized = courseName.toLowerCase();

  if (_matchesAny(normalized, [
    'mate',
    'álgebra',
    'algebra',
    'cálculo',
    'calculo',
  ])) {
    return Icons.functions_rounded;
  }
  if (_matchesAny(normalized, ['física', 'fisica'])) {
    return Icons.bolt_rounded;
  }
  if (_matchesAny(normalized, ['química', 'quimica', 'lab'])) {
    return Icons.science_rounded;
  }
  if (_matchesAny(normalized, ['bio', 'anatom', 'medicina'])) {
    return Icons.biotech_rounded;
  }
  if (_matchesAny(normalized, ['historia', 'social', 'derecho', 'política'])) {
    return Icons.account_balance_rounded;
  }
  if (_matchesAny(normalized, ['arte', 'diseño', 'diseno', 'music'])) {
    return Icons.palette_rounded;
  }
  if (_matchesAny(normalized, ['program', 'código', 'codigo', 'software'])) {
    return Icons.code_rounded;
  }
  if (_matchesAny(normalized, ['inglés', 'ingles', 'idioma', 'literatura'])) {
    return Icons.menu_book_rounded;
  }
  return Icons.school_rounded;
}

bool _matchesAny(String value, List<String> patterns) {
  return patterns.any(value.contains);
}
