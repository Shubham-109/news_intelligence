import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton.dart';

/// Loading placeholder shaped like the article list, so content does not
/// jump around when it arrives.
class ArticleListSkeleton extends StatelessWidget {
  const ArticleListSkeleton({super.key, this.showLead = false});

  final bool showLead;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          if (showLead) const _LeadPlaceholder(),
          for (var i = 0; i < 6; i++) const _TilePlaceholder(),
        ],
      ),
    );
  }
}

class _LeadPlaceholder extends StatelessWidget {
  const _LeadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: SkeletonBlock(height: double.infinity, radius: 14),
          ),
          SizedBox(height: 16),
          SkeletonBlock(width: 72, height: 10),
          SizedBox(height: 12),
          SkeletonBlock(height: 22),
          SizedBox(height: 8),
          SkeletonBlock(width: 220, height: 22),
          SizedBox(height: 14),
          SkeletonBlock(width: 120, height: 10),
        ],
      ),
    );
  }
}

class _TilePlaceholder extends StatelessWidget {
  const _TilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 60, height: 10),
                SizedBox(height: 10),
                SkeletonBlock(height: 16),
                SizedBox(height: 6),
                SkeletonBlock(width: 180, height: 16),
                SizedBox(height: 12),
                SkeletonBlock(width: 90, height: 10),
              ],
            ),
          ),
          SizedBox(width: 16),
          SkeletonBlock(width: 88, height: 88, radius: 10),
        ],
      ),
    );
  }
}
