import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum DiftiriTone { navy, emerald, mint }

class DiftiriIconBox extends StatelessWidget {
  const DiftiriIconBox({
    super.key,
    required this.icon,
    this.tone = DiftiriTone.emerald,
    this.size = 54,
    this.iconSize,
  });

  final IconData icon;
  final DiftiriTone tone;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final light = tone == DiftiriTone.mint;
    final colors = switch (tone) {
      DiftiriTone.navy => const [
          Color(0xFF1B5D88),
          Color(0xFF0B3150),
        ],
      DiftiriTone.emerald => const [
          Color(0xFF18C9A5),
          Color(0xFF07866D),
        ],
      DiftiriTone.mint => const [
          Color(0xFFF7FFFD),
          Color(0xFFDDF8F1),
        ],
    };

    final frontColor =
        light ? AppColors.emeraldDark : Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(size * .27),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: light ? .96 : .22,
          ),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (light ? AppColors.emerald : colors.last)
                .withValues(alpha: .24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Color(0x35FFFFFF),
            blurRadius: 2,
            offset: Offset(-1, -1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * .13,
            right: size * .14,
            child: Container(
              width: size * .24,
              height: size * .08,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: light ? .92 : .14,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 2),
            child: Icon(
              icon,
              size: iconSize ?? size * .5,
              color: frontColor,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(
                    alpha: light ? .10 : .26,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiftiriAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DiftiriAppBar({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.tone = DiftiriTone.emerald,
    this.actions = const [],
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final DiftiriTone tone;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        bottom == null
            ? 86
            : 86 + bottom!.preferredSize.height,
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 86,
      automaticallyImplyLeading: true,
      titleSpacing: 6,
      title: Row(
        children: [
          DiftiriIconBox(
            icon: icon,
            tone: tone,
            size: 50,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

class DiftiriSurface extends StatelessWidget {
  const DiftiriSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D123E63),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

class DiftiriSectionHeader extends StatelessWidget {
  const DiftiriSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class DiftiriEmptyState extends StatelessWidget {
  const DiftiriEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DiftiriIconBox(
                icon: icon,
                tone: DiftiriTone.mint,
                size: 74,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DiftiriPrimaryButton extends StatelessWidget {
  const DiftiriPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.expanded = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    return expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
