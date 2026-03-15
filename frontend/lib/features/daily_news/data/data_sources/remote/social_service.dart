import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/comment_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment_entity.dart';

class SocialService {
  final FirebaseFirestore _firestore;

  SocialService(this._firestore);

  User? get _user => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>> _articleRef(String articleId) =>
      _firestore.collection('articles').doc(articleId);

  Future<void> toggleLike(String articleId) async {
    final uid = _user!.uid;
    final likeRef = _articleRef(articleId).collection('likes').doc(uid);
    await _firestore.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final articleSnap = await tx.get(_articleRef(articleId));
      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(_articleRef(articleId), {
          'likeCount': (articleSnap.data()?['likeCount'] ?? 1) - 1,
        });
      } else {
        tx.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
        tx.update(_articleRef(articleId), {
          'likeCount': (articleSnap.data()?['likeCount'] ?? 0) + 1,
        });
      }
    });
  }

Future<void> addComment(String articleId, String text) async {
    final user = _user!;
    final authorName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email?.split('@').first ?? 'Anonymous';
    final commentRef = _articleRef(articleId).collection('comments').doc();
    await _firestore.runTransaction((tx) async {
      final articleSnap = await tx.get(_articleRef(articleId));
      tx.set(commentRef, {
        'authorId': user.uid,
        'authorName': authorName,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(_articleRef(articleId), {
        'commentCount': (articleSnap.data()?['commentCount'] ?? 0) + 1,
      });
    });
  }

  Stream<List<CommentEntity>> watchComments(String articleId) {
    return _articleRef(articleId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CommentModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<bool> isLiked(String articleId) async {
    final uid = _user?.uid;
    if (uid == null) return false;
    final doc = await _articleRef(articleId).collection('likes').doc(uid).get();
    return doc.exists;
  }

  Future<Map<String, int>> getArticleCounts(String articleId) async {
    final doc = await _articleRef(articleId).get();
    final data = doc.data() ?? {};
    return {
      'likeCount': (data['likeCount'] as num?)?.toInt() ?? 0,
      'commentCount': (data['commentCount'] as num?)?.toInt() ?? 0,
    };
  }
}
