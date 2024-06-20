import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createShoppingList({
  required BuildContext context,
  required FirebaseAuth auth,
  required String listName,
  String? listDescription,
}) async {
  User? user = auth.currentUser;

  if (user != null) {
    if (listName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('List name cannot be empty')),
      );
      return;
    }

    Map<String, dynamic> listData = {
      'name': listName,
      'description': listDescription ?? '',
    };

    await FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(user.uid)
        .collection('user_lists')
        .add(listData);
  } else {
    debugPrint("User is not logged in.");
  }
}
