import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteShoppingList({
  required BuildContext context,
  required FirebaseAuth auth,
  required String listId,
  required String listName,
}) async {
  User? user = auth.currentUser;

  if (user != null) {
    bool confirm = await _showConfirmationDialog(context, listName);
    if (confirm) {
      await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(listId)
          .delete();
    }
  } else {
    debugPrint("User is not logged in.");
  }
}

Future<bool> _showConfirmationDialog(
    BuildContext context, String listName) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Confirm Deletion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content:
                Text('Are you sure you want to delete the list "$listName"?'),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  backgroundColor: Colors.grey.withOpacity(0.1),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        },
      ) ??
      false;
}
