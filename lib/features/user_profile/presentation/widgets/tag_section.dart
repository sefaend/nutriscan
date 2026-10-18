import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Başlık + silinebilir etiketler + "+" butonu.
/// Alerjiler (kırmızı) ve Diyet Tercihleri (yeşil) için ortak kullanılır.
class TagSection extends StatelessWidget {
  const TagSection({
    super.key,
    required this.title,
    required this.tags,
    required this.tagColor,
    required this.onRemove,
    required this.onAdd,
  });

  final String title;
  final List<String> tags;
  final Color tagColor;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final tag in tags)
              _Tag(
                color: tagColor,
                label: tag,
                trailing: Icons.close_rounded,
                onTap: () => onRemove(tag),
              ),
            _Tag(color: tagColor, trailing: Icons.add_rounded, onTap: onAdd),
          ],
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.color,
    required this.trailing,
    required this.onTap,
    this.label,
  });

  final Color color;
  final String? label;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: label == null ? 8 : 10,
            vertical: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(trailing, size: 14, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
