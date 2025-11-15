import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String imageUrl;
  final String groupName;
  final String? timeLastPublish;
  final int notifications;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.imageUrl,
    required this.groupName,
    this.timeLastPublish,
    required this.notifications,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Imagem circular
              CircleAvatar(radius: 25, backgroundImage: NetworkImage(imageUrl)),
              const SizedBox(width: 12),
              // Nome do grupo
              Expanded(
                child: Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Hora + notificações
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // if (timeLastPublish != null)
                  //   Text(
                  //     timeLastPublish!,
                  //     style: TextStyle(
                  //       color: Colors.grey[600],
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // const SizedBox(height: 4),
                  if (notifications > 0)
                    Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          notifications.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
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
