import 'package:equatable/equatable.dart';

abstract class FirestoreArticlesEvent extends Equatable {
  const FirestoreArticlesEvent();

  @override
  List<Object?> get props => [];
}

class GetFirestoreArticles extends FirestoreArticlesEvent {
  const GetFirestoreArticles();
}

class DeleteFirestoreArticle extends FirestoreArticlesEvent {
  final String firestoreId;
  const DeleteFirestoreArticle(this.firestoreId);

  @override
  List<Object?> get props => [firestoreId];
}
