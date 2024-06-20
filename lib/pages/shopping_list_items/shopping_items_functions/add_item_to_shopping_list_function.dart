import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> addItemToShoppingList({
  required FirebaseAuth auth,
  required String listId,
  required String itemName,
  int quantity = 1,
}) async {
  User? user = auth.currentUser;

  if (user != null && itemName.isNotEmpty) {
    await FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(user.uid)
        .collection('user_lists')
        .doc(listId)
        .collection('items')
        .add({
      'name': itemName,
      'quantity': quantity,
      'isChecked': false,
    });
  } else {
    debugPrint("User is not logged in or item name is empty.");
  }
}
