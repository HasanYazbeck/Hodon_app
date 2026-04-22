import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide theme mode state (light/dark).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

