import 'package:flutter/material.dart';

extension ContextColors on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground => cs.surface;
  Color get appSurface => cs.surface;
  Color get appSurfaceVariant => cs.surfaceContainerHighest;
  Color get appBorder => cs.outlineVariant;
  Color get appTextPrimary => cs.onSurface;
  Color get appTextSecondary => cs.onSurfaceVariant;
  Color get appTextHint => cs.onSurfaceVariant.withValues(alpha: 0.7);
}

