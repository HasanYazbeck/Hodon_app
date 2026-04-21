import 'package:flutter/material.dart';

/// Hodon brand color palette — soft premium childcare aesthetic.
class AppColors {
  AppColors._();

  // Primary — lavender/purple
  static const Color primary = Color(0xFF7C5CBF);
  static const Color primaryLight = Color(0xFFA88FD4);
  static const Color primaryDark = Color(0xFF5A3D9A);
  static const Color primaryContainer = Color(0xFFEDE7FF);

  // Secondary — warm blush
  static const Color secondary = Color(0xFFE8A0B4);
  static const Color secondaryLight = Color(0xFFF3C4D4);
  static const Color secondaryDark = Color(0xFFD07A96);
  static const Color secondaryContainer = Color(0xFFFFF0F4);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoContainer = Color(0xFFE3F2FD);

  // Emergency accent
  static const Color emergency = Color(0xFFFF5252);
  static const Color emergencyContainer = Color(0xFFFFEBEB);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F0F9);
  static const Color divider = Color(0xFFEAE7F2);
  static const Color border = Color(0xFFDDD8ED);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color textHint = Color(0xFFAAAAAC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF1A1A2E);

  // Badges / Trust
  static const Color badgeGold = Color(0xFFFFB300);
  static const Color badgeVerified = Color(0xFF43A047);
  static const Color badgeTrustCircle = Color(0xFF7C5CBF);
  static const Color badgeCPR = Color(0xFFE53935);

  // Chat
  static const Color bubbleSent = Color(0xFF7C5CBF);
  static const Color bubbleReceived = Color(0xFFF3F0F9);

  // Shimmer
  static const Color shimmerBase = Color(0xFFEDE7FF);
  static const Color shimmerHighlight = Color(0xFFF9F7FF);

  // Shadow
  static Color shadow = const Color(0xFF7C5CBF).withValues(alpha: 0.08);
  static Color cardShadow = const Color(0xFF000000).withValues(alpha: 0.06);
}

