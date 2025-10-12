import 'package:flutter/material.dart';

class CustomPopupMenu extends StatelessWidget {
  final List<PopupMenuItemData> items;
  final Icon icon;

  const CustomPopupMenu({
    super.key,
    required this.items,
    this.icon = const Icon(Icons.more_vert, size: 25),
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: icon,
      onSelected: (value) {
        final selectedItem = items.firstWhere(
          (element) => element.value == value,
        );
        selectedItem.onTap();
      },
      itemBuilder: (BuildContext context) {
        return items.map((item) {
          return PopupMenuItem<String>(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(item.label),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

class PopupMenuItemData {
  final String value;
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  PopupMenuItemData({
    required this.value,
    required this.label,
    required this.onTap,
    this.icon,
  });
}
