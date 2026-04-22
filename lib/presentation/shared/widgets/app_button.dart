import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final double height;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.height = AppSizes.buttonHeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildElevated(theme);
      case AppButtonVariant.secondary:
        return _buildSecondary(theme);
      case AppButtonVariant.outline:
        return _buildOutlined(theme);
      case AppButtonVariant.ghost:
        return _buildText(theme);
      case AppButtonVariant.danger:
        return _buildDanger(theme);
    }
  }

  Widget _buildContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.onPrimary,
        ),
      );
    }
    if (leadingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [leadingIcon!, const SizedBox(width: AppSizes.sm), Text(label)],
      );
    }
    return Text(label);
  }


  Widget _buildElevated(ThemeData theme) => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: theme.elevatedButtonTheme.style?.copyWith(
          minimumSize: WidgetStateProperty.all(
            Size(isFullWidth ? double.infinity : 120, height),
          ),
          textStyle: WidgetStateProperty.all(
            TextStyle(fontSize: fontSize ?? 15, fontWeight: FontWeight.w600),
          ),
        ),
        child: _buildContent(theme),
      );

  Widget _buildSecondary(ThemeData theme) => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          elevation: 0,
          minimumSize: Size(isFullWidth ? double.infinity : 120, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
        child: _buildContent(theme),
      );

  Widget _buildOutlined(ThemeData theme) => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: theme.outlinedButtonTheme.style?.copyWith(
          minimumSize: WidgetStateProperty.all(
            Size(isFullWidth ? double.infinity : 120, height),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (leadingIcon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [leadingIcon!, const SizedBox(width: AppSizes.sm), Text(label)],
                  )
                : Text(label)),
      );

  Widget _buildText(ThemeData theme) => TextButton(
        onPressed: isLoading ? null : onPressed,
        child: Text(label),
      );

  Widget _buildDanger(ThemeData theme) => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          elevation: 0,
          minimumSize: Size(isFullWidth ? double.infinity : 120, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
        child: _buildContent(theme),
      );
}

