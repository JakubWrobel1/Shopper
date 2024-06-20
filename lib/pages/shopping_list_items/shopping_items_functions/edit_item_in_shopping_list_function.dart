import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> editItemInShoppingList({
  required FirebaseAuth auth,
  required String listId,
  required String itemId,
  required String newName,
  required int newQuantity,
}) async {
  User? user = auth.currentUser;

  if (user != null && newName.isNotEmpty) {
    FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(user.uid)
        .collection('user_lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .update({
      'name': newName,
      'quantity': newQuantity,
    });
  } else {
    debugPrint("User is not logged in or new item name is empty.");
  }
}
