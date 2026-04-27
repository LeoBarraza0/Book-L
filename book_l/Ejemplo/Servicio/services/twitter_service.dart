import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/tweet.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../models/message.dart';
import '../models/trend.dart';

// Servicio que simula un backend (trabaja con JSON + memoria)
class TwitterService {
  // "Base de datos" en memoria
  List<Tweet> tweets = [];
  List<User> users = [];
  List<Comment> comments = [];
  List<Message> messages = [];
  List<Trend> trends = [];

  bool loaded = false; // Controla si ya cargamos el JSON

  // Inicializa los datos desde el JSON
  Future<void> init() async {
    if (loaded) return;

    // Carga el archivo JSON desde assets
    final response =
        await rootBundle.loadString('assets/data/twitter_data.json');

    final data = json.decode(response);

    // Cargar usuarios
    users = (data['usuarios'] as List)
        .map((u) => User(
              id: u['id'],
              username: u['username'],
              nombre: u['nombre'],
              avatar: u['avatar'],
            ))
        .toList();

    // Cargar tweets
    tweets = (data['tweets'] as List)
        .map((t) => Tweet(
              id: t['id'],
              userId: t['user_id'],
              contenido: t['contenido'],
              likes: List<int>.from(t['likes']),
            ))
        .toList();

    // Cargar comentarios
    comments = (data['comentarios'] as List)
        .map((c) => Comment(
              id: c['id'],
              tweetId: c['tweet_id'],
              userId: c['user_id'],
              contenido: c['contenido'],
            ))
        .toList();

    // Cargar mensajes
    messages = (data['mensajes'] as List)
        .map((m) => Message(
              id: m['id'],
              de: m['de'],
              para: m['para'],
              contenido: m['contenido'],
              leido: m['leido'],
            ))
        .toList();

    // Cargar tendencias
    trends = (data['tendencias'] as List)
        .map((t) => Trend(
              id: t['id'],
              hashtag: t['hashtag'],
              cantidad: t['cantidad'],
            ))
        .toList();

    loaded = true;
  }

  // READ → obtener tweets
  List<Tweet> getTweets() => tweets;

  // Obtener usuario por ID (relación)
  User getUser(int id) {
    return users.firstWhere((u) => u.id == id);
  }

  // Obtener comentarios de un tweet
  List<Comment> getCommentsByTweet(int tweetId) {
    return comments.where((c) => c.tweetId == tweetId).toList();
  }

  // CREATE → crear tweet
  void addTweet(String contenido) {
    tweets.add(
      Tweet(
        id: tweets.isEmpty ? 1 : tweets.last.id + 1,
        userId: 1,
        contenido: contenido,
        likes: [],
      ),
    );
  }

  // UPDATE → editar tweet
  void updateTweet(int tweetId, String nuevoContenido) {
    final index = tweets.indexWhere((t) => t.id == tweetId);

    if (index != -1) {
      tweets[index].contenido = nuevoContenido;
    }
  }

  // DELETE → eliminar tweet
  void deleteTweet(int tweetId) {
    tweets.removeWhere((t) => t.id == tweetId);
  }

  // LIKE → dar like
  void likeTweet(int tweetId) {
    final tweet = tweets.firstWhere((t) => t.id == tweetId);

    if (!tweet.likes.contains(1)) {
      tweet.likes.add(1);
    }
  }
}
