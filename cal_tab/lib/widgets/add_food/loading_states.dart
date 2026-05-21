import 'package:flutter/material.dart';

class LoadingProductList extends StatelessWidget {
  const LoadingProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      itemBuilder: (context, index) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.vertical(
            top: index == 0 ? const Radius.circular(18) : Radius.zero,
            bottom: index == 5 ? const Radius.circular(18) : Radius.zero,
          ),
          border: Border(
            bottom: BorderSide(
              color: index == 5 ? Colors.transparent : colors.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              _SkeletonBox(width: 58, height: 58),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 180, height: 16),
                    SizedBox(height: 10),
                    _SkeletonBox(width: 96, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      itemCount: 6,
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(width: widget.width, height: widget.height),
      ),
    );
  }
}
