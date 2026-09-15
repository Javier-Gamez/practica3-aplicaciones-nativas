import 'package:flutter/material.dart';

/// Shows the current path as a row of tappable segments, always visible so
/// the user knows where they are in the sandbox hierarchy.
class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({
    super.key,
    required this.segments,
    required this.onTapRoot,
    required this.onTapSegment,
  });

  final List<String> segments;
  final VoidCallback onTapRoot;
  final ValueChanged<int> onTapSegment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _crumb(context, 'Inicio', onTapRoot, isLast: segments.isEmpty),
          for (var i = 0; i < segments.length; i++) ...[
            Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
            _crumb(context, segments[i], () => onTapSegment(i), isLast: i == segments.length - 1),
          ],
        ],
      ),
    );
  }

  Widget _crumb(BuildContext context, String label, VoidCallback onTap, {required bool isLast}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: isLast ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isLast ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
