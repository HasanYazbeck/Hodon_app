import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSizes.avatarMd,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (_isDataImageUri(imageUrl)) {
      final bytes = _decodeDataImageUri(imageUrl!);
      avatar = bytes != null
          ? CircleAvatar(
              radius: size / 2,
              backgroundImage: MemoryImage(bytes),
            )
          : _fallbackAvatar();
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (ctx, imageProvider) => CircleAvatar(
          radius: size / 2,
          backgroundImage: imageProvider,
        ),
        placeholder: (ctx, url) => _shimmerCircle(),
        errorWidget: (ctx, url, error) => _fallbackAvatar(),
      );
    } else {
      avatar = _fallbackAvatar();
    }

    if (showBorder) {
      avatar = Container(
        width: size + 4,
        height: size + 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? AppColors.primary,
            width: 2,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  bool _isDataImageUri(String? value) =>
      value != null && value.startsWith('data:image') && value.contains(',');

  Uint8List? _decodeDataImageUri(String value) {
    final comma = value.indexOf(',');
    if (comma < 0 || comma == value.length - 1) return null;
    try {
      return base64Decode(value.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  Widget _fallbackAvatar() {
    final initials = name != null && name!.isNotEmpty
        ? name!.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _shimmerCircle() => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: CircleAvatar(radius: size / 2, backgroundColor: AppColors.shimmerBase),
      );
}

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius = AppSizes.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    final base = context.isDarkMode ? context.appSurfaceVariant : AppColors.shimmerBase;
    final highlight = context.isDarkMode
        ? context.appSurfaceVariant.withValues(alpha: 0.65)
        : AppColors.shimmerHighlight;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final base = context.isDarkMode ? context.appSurfaceVariant : AppColors.shimmerBase;
    final highlight = context.isDarkMode
        ? context.appSurfaceVariant.withValues(alpha: 0.65)
        : AppColors.shimmerHighlight;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pageHorizontal,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            CircleAvatar(radius: AppSizes.avatarMd / 2, backgroundColor: base),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 150, decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  )),
                  const SizedBox(height: AppSizes.xs),
                  Container(height: 12, width: 100, decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showLabel;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 14,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.badgeGold, size: size),
        const SizedBox(width: 2),
        if (showLabel)
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size - 2,
              fontWeight: FontWeight.w600,
              color: context.appTextPrimary,
            ),
          ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSizes.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class HodonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const HodonCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.appSurface;
    final borderColor = context.appBorder;

    return Material(
      color: color ?? surfaceColor,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: child,
        ),
      ),
    );
  }
}

class TrustBadgeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const TrustBadgeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

