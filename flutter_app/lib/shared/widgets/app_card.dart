import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? radius;

  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.onTap,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.card,
      borderRadius: BorderRadius.circular(radius ?? AppSpacing.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius ?? AppSpacing.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(radius ?? AppSpacing.radiusCard),
          ),
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
