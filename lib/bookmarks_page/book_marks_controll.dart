import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/auth_service.dart';

Future<void> addBookmark(WidgetRef ref, Map<String, dynamic> place) async {
  final user = ref.read(authStateProvider).value;
  if (user == null) return;

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('bookmarks')
      .doc();

  await docRef.set(place);
}

Future<void> deleteBookmark(WidgetRef ref, String bookmarkId) async {
  final user = ref.read(authStateProvider).value;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('bookmarks')
      .doc(bookmarkId)
      .delete();
}