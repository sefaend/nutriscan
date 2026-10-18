import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// "+" butonuna basınca açılır. Hazır öneriler seçilebilir ya da elle yazılır.
/// Seçilen/yazılan metni döndürür; vazgeçilirse null.
Future<String?> showAddItemDialog(
  BuildContext context, {
  required String title,
  required List<String> suggestions,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _AddItemDialog(title: title, suggestions: suggestions),
  );
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog({required this.title, required this.suggestions});

  final String title;
  final List<String> suggestions;

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _text.text.trim();
    if (value.isNotEmpty) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _text,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(hintText: 'Type here...'),
            ),
            if (widget.suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final s in widget.suggestions)
                    ActionChip(
                      label: Text(s),
                      onPressed: () => Navigator.of(context).pop(s),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(onPressed: _submit, child: const Text(AppStrings.add)),
      ],
    );
  }
}
