import 'package:flutter/material.dart';

class SeguidoresScreen extends StatelessWidget {
  const SeguidoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB), // General BackGround
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF88D288),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
        title: const Text(
          'Seguidores',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 15, // Followers Placeholder
                itemBuilder: (context, index) {
                  return _buildSeguidorItem(
                    name: 'Usuario ${index + 1}',
                    username: '@user${index + 1}',
                    imageUrl:
                        'https://i.pravatar.cc/150?img=${index + 10}', // Random Images
                    isFollowing: index % 3 == 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeguidorItem({
    required String name,
    required String username,
    required String imageUrl,
    required bool isFollowing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(2), // Border
            decoration: const BoxDecoration(
              color: Color(0xFF4DC130), // Green border of image
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(width: 15),

          // Nombres
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  username,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // Action Button
          ElevatedButton(
            onPressed: () {
              // Logic to follow or unfollow
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing
                  ? const Color(0xFFE3EFFC)
                  : const Color(0xFF4DC130),
              foregroundColor: isFollowing ? Colors.black87 : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              isFollowing ? 'Siguiendo' : 'Seguir',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
