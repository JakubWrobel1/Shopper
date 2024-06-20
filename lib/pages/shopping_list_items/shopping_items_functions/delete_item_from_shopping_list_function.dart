import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> deleteItemFromShoppingList({
  required FirebaseAuth auth,
  required String listId,
  required String itemId,
}) async {
  User? user = auth.currentUser;

  if (user != null) {
    await FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(user.uid)
        .collection('user_lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .delete();
  } else {
    debugPrint("User is not logged in.");
  }
}
