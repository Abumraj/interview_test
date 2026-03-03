import 'package:flutter/material.dart';
import 'package:interview/const.dart';

Future<T?> showAppDropdownSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelBuilder,
  T? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: false,
    builder: (ctx) {
      final bottomPadding = MediaQuery.of(ctx).viewPadding.bottom;
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(null),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder:
                      (context, index) =>
                          const Divider(height: 1, color: Colors.white12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = selected != null && item == selected;
                    return ListTile(
                      onTap: () => Navigator.of(ctx).pop(item),
                      dense: true,
                      title: Text(
                        labelBuilder(item),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                              : null,
                    );
                  },
                ),
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      );
    },
  );
}
