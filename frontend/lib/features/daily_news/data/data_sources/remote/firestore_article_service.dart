import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class FirestoreArticleService {
  final FirebaseFirestore _firestore;

  FirestoreArticleService(this._firestore);

  Future<List<ArticleModel>> getArticles() async {
    final snapshot = await _firestore.collection('articles').get();
    return snapshot.docs
        .map((doc) => ArticleModel.fromFirestore(doc.data()))
        .toList();
  }

  Stream<List<ArticleModel>> watchArticles() {
    return _firestore.collection('articles').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ArticleModel.fromFirestore(doc.data()))
              .toList(),
        );
  }

  Future<void> uploadArticle(ArticleModel article) async {
    await _firestore.collection('articles').add(article.toJson());
  }
}
