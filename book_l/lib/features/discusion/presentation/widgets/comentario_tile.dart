import 'package:flutter/material.dart';

class ComentarioTile extends StatelessWidget {
  final String name;
  final String content;
  final String time;
  final String likes;

  const ComentarioTile({
    super.key,
    required this.name,
    required this.content,
    required this.time,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black87,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(content, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(time, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Text(likes, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    const Text('Responder', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
