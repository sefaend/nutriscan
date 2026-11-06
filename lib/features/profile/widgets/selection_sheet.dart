import 'package:flutter/material.dart';

class SelectionSheet extends StatefulWidget {
  final String title;
  final Map<String, String> options;
  final List<String> currentSelections;
  final Function(String key) onSelect;

  const SelectionSheet({
    required this.title,
    required this.options,
    required this.currentSelections,
    required this.onSelect,
  });

  @override
  State<SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> {
  final TextEditingController _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _select(String value) {
    FocusScope.of(context).unfocus();
    widget.onSelect(value);
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _submitOther() {
    final text = _otherController.text.trim();
    if (text.isEmpty) return;
    _select(text);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final key = widget.options.keys.elementAt(index);
                    final label = widget.options.values.elementAt(index);
                    final isSelected = widget.currentSelections.contains(key);

                    return ListTile(
                      title: Text(
                        label,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? primary : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: primary)
                          : const Icon(Icons.add_circle_outline_rounded),
                      onTap: () => _select(key),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _otherController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitOther(),
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Other (type here)',
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: const Color(0xFFF1F3F4),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_rounded),
                    color: primary,
                    iconSize: 32,
                    onPressed: _submitOther,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
