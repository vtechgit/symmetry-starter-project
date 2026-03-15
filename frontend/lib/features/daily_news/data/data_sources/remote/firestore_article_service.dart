import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class FirestoreArticleService {
  final FirebaseFirestore _firestore;

  FirestoreArticleService(this._firestore);

  Future<List<ArticleModel>> getArticles() async {
    final snapshot = await _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ArticleModel.fromFirestore(doc.data(), docId: doc.id))
        .toList();
  }

  Stream<List<ArticleModel>> watchArticles() {
    return _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ArticleModel.fromFirestore(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  Future<void> uploadArticle(ArticleModel article, {required String authorId}) async {
    await _firestore.collection('articles').add(article.toJson(authorId: authorId));
  }

  Future<void> deleteArticle(String articleId) async {
    await _firestore.collection('articles').doc(articleId).delete();
  }
}
