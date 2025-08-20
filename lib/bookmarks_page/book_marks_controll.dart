import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/auth_service.dart';

class BookmarksController {
  final Ref _ref;

  BookmarksController(this._ref);

  Future<void> addBookmark(Map<String, dynamic> place) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bookmarks')
            .doc();

    await docRef.set(place);
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(bookmarkId)
        .delete();
  }
}

final bookmarksControllerProvider = Provider<BookmarksController>((ref) {
  return BookmarksController(ref);
});
