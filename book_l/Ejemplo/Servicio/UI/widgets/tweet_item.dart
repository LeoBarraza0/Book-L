import 'package:flutter/material.dart';
import '../../models/tweet.dart';
import '../../models/user.dart';

// Widget reutilizable para mostrar un tweet
class TweetItem extends StatelessWidget {
  final Tweet tweet;
  final User user;
  final VoidCallback onLike;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TweetItem({
    super.key,
    required this.tweet,
    required this.user,
    required this.onLike,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Avatar del usuario
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.avatar),
      ),

      // Username
      title: Text(user.username),

      // Contenido del tweet + likes
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tweet.contenido),
          Text("❤️ ${tweet.likes.length} likes"),
        ],
      ),

      // Acciones CRUD
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.favorite), onPressed: onLike),
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
    );
  }
}
