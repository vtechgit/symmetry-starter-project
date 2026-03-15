import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class BookmarkService {
  final FirebaseFirestore _firestore;

  BookmarkService(this._firestore);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _stableId(ArticleEntity article) {
    if (article.firestoreId != null && article.firestoreId!.isNotEmpty) {
      return article.firestoreId!;
    }
    final key = article.url ?? article.title ?? article.hashCode.toString();
    return base64Url.encode(utf8.encode(key)).replaceAll('=', '');
  }

  Future<List<ArticleEntity>> getBookmarks() async {
    final uid = _uid;
    if (uid == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .orderBy('savedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final d = doc.data();
      return ArticleEntity(
        firestoreId: (d['firestoreId'] as String?)?.isNotEmpty == true ? d['firestoreId'] as String : null,
        authorId: d['authorId'] as String?,
        author: d['author'] as String?,
        title: d['title'] as String?,
        description: d['description'] as String?,
        url: d['url'] as String?,
        urlToImage: d['urlToImage'] as String?,
        publishedAt: d['publishedAt'] as String?,
        content: d['content'] as String?,
      );
    }).toList();
  }

  Future<void> saveBookmark(ArticleEntity article) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(_stableId(article))
        .set({
      'firestoreId': article.firestoreId,
      'authorId': article.authorId ?? '',
      'author': article.author ?? '',
      'title': article.title ?? '',
      'description': article.description ?? '',
      'url': article.url ?? '',
      'urlToImage': article.urlToImage ?? '',
      'publishedAt': article.publishedAt ?? '',
      'content': article.content ?? '',
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(ArticleEntity article) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(_stableId(article))
        .delete();
  }
}
