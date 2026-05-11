import 'package:flutter/material.dart';

/// Lightweight shimmer-style skeleton primitives.
///
/// Self-contained (no third-party dependency). Uses an AnimatedBuilder driven
/// by a single repeating controller and a ShaderMask gradient sweep.
///
/// Usage:
///   SkeletonBox(width: 120, height: 14)
///   SkeletonAvatar(size: 48)
///   SkeletonListTile()
///   SkeletonList(itemBuilder: (_, __) => SkeletonListTile())
///
/// Wrap a tree with [Skeletonizer] to apply shimmer once to the whole subtree
/// (more efficient than wrapping each box individually):
///   Skeletonizer(child: Column(children: [SkeletonBox(...), ...]))

/// Wraps a subtree with the shimmer animation (single shader sweep across all
/// `SkeletonBox` / `SkeletonAvatar` descendants painted via this widget).
class Skeletonizer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const Skeletonizer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<Skeletonizer> createState() => _SkeletonizerState();
}

class _SkeletonizerState extends State<Skeletonizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double t = _controller.value;
            return LinearGradient(
              begin: Alignment(-1.0 + t * 2, -0.3),
              end: Alignment(0.0 + t * 2, 0.3),
              colors: const [
                Color(0xFFE6E8EB),
                Color(0xFFF4F5F7),
                Color(0xFFE6E8EB),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single skeleton placeholder rectangle.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8EB),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Circular skeleton (avatar / icon placeholder).
class SkeletonAvatar extends StatelessWidget {
  final double size;
  const SkeletonAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE6E8EB),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A single placeholder line of text.
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonText({
    super.key,
    this.width = 120,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(width: width, height: height, borderRadius: BorderRadius.circular(6));
  }
}

/// Skeleton list tile (avatar + 2 text lines).
class SkeletonListTile extends StatelessWidget {
  final bool hasTrailing;
  final EdgeInsets padding;

  const SkeletonListTile({
    super.key,
    this.hasTrailing = false,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SkeletonAvatar(size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonText(width: 140, height: 12),
                SizedBox(height: 8),
                SkeletonText(width: 200, height: 10),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 12),
            const SkeletonBox(width: 24, height: 24),
          ],
        ],
      ),
    );
  }
}

/// A column of skeleton list tiles, wrapped in a single Skeletonizer.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;
  final EdgeInsets padding;
  final double itemSpacing;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.itemSpacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Padding(
        padding: padding,
        child: Column(
          children: List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : itemSpacing),
              child: itemBuilder?.call(context, index) ?? const SkeletonListTile(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton card for vehicle/ride options (icon + name + price + ETA).
class SkeletonRideOptionCard extends StatelessWidget {
  const SkeletonRideOptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 56, height: 40, borderRadius: BorderRadius.all(Radius.circular(8))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonText(width: 90, height: 13),
                SizedBox(height: 8),
                SkeletonText(width: 140, height: 10),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SkeletonText(width: 60, height: 14),
        ],
      ),
    );
  }
}

/// Horizontal row of small service-style cards (icon + label).
class SkeletonServiceRow extends StatelessWidget {
  final int itemCount;
  const SkeletonServiceRow({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) {
            return Container(
              width: 86,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAECEF)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SkeletonBox(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(12))),
                  SizedBox(height: 10),
                  SkeletonText(width: 50, height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
