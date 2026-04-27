import 'package:flutter/material.dart';
import '../../services/twitter_service.dart';
import '../widgets/tweet_item.dart';

// Pantalla principal
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = TwitterService();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Carga inicial del JSON
  void loadData() async {
    await service.init();
    setState(() {});
  }

  // LIKE
  void like(int id) {
    service.likeTweet(id);
    setState(() {});
  }

  // DIALOG para crear o editar
  void showTweetDialog({int? tweetId, String? contenido}) {
    final controller = TextEditingController(text: contenido ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tweetId == null ? "Nuevo Tweet" : "Editar Tweet"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (tweetId == null) {
                service.addTweet(controller.text);
              } else {
                service.updateTweet(tweetId, controller.text);
              }

              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  // DELETE
  void delete(int id) {
    service.deleteTweet(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tweets = service.getTweets();

    return Scaffold(
      appBar: AppBar(title: const Text("MiniTwitter")),

      body: ListView.builder(
        itemCount: tweets.length,
        itemBuilder: (_, index) {
          final tweet = tweets[index];
          final user = service.getUser(tweet.userId);

          return TweetItem(
            tweet: tweet,
            user: user,
            onLike: () => like(tweet.id),
            onEdit: () =>
                showTweetDialog(tweetId: tweet.id, contenido: tweet.contenido),
            onDelete: () => delete(tweet.id),
          );
        },
      ),

      // CREATE
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTweetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
