import 'package:flutter/material.dart';

/// Optimized list tile dengan minimal rebuilds
class OptimizedListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const OptimizedListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: contentPadding ?? const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Optimized card widget dengan RepaintBoundary
class OptimizedCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const OptimizedCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: margin,
        child: Material(
          color: color ?? Colors.white,
          elevation: elevation ?? 2.0,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cached builder untuk expensive widgets
class CachedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final bool shouldRebuild;

  const CachedBuilder({
    super.key,
    required this.builder,
    this.shouldRebuild = false,
  });

  @override
  State<CachedBuilder> createState() => _CachedBuilderState();
}

class _CachedBuilderState extends State<CachedBuilder> {
  Widget? _cachedWidget;

  @override
  Widget build(BuildContext context) {
    if (_cachedWidget == null || widget.shouldRebuild) {
      _cachedWidget = widget.builder(context);
    }
    return _cachedWidget!;
  }
}

/// Optimized image container dengan lazy loading
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          // Optimize caching
          cacheWidth: width?.toInt(),
          cacheHeight: height?.toInt(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: width,
              height: height,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.error, color: Colors.red),
            );
          },
        ),
      ),
    );
  }
}

/// Lazy list dengan automatic pagination
class LazyListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<List<T>> Function()? onLoadMore;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const LazyListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.physics,
    this.padding,
  });

  @override
  State<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<LazyListView<T>> {
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: widget.physics ?? const BouncingScrollPhysics(),
      padding: widget.padding,
      itemCount: widget.items.length + (widget.onLoadMore != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          // Load more trigger
          if (!_isLoadingMore && widget.onLoadMore != null) {
            _loadMore();
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return RepaintBoundary(
          child: widget.itemBuilder(context, widget.items[index], index),
        );
      },
    );
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;

    setState(() => _isLoadingMore = true);
    try {
      final newItems = await widget.onLoadMore!();
      if (mounted && newItems.isNotEmpty) {
        setState(() {
          widget.items.addAll(newItems);
        });
      }
    } catch (e) {
      debugPrint('Error loading more: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }
}

/// Animated loading shimmer
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}
