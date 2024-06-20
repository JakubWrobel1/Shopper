import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> editShoppingList({
  required BuildContext context,
  required FirebaseAuth auth,
  required TextEditingController listNameController,
  required TextEditingController listDescriptionController,
  required String listId,
  required String currentName,
  required String currentDescription,
}) async {
  listNameController.text = currentName;
  listDescriptionController.text = currentDescription;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Shopping List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: listNameController,
              decoration: const InputDecoration(labelText: 'List Name'),
            ),
            TextField(
              controller: listDescriptionController,
              decoration: const InputDecoration(labelText: 'List Description'),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
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
            onPressed: () async {
              if (listNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('List name cannot be empty')),
                );
                return;
              }
              await FirebaseFirestore.instance
                  .collection('shopping_lists')
                  .doc(auth.currentUser!.uid)
                  .collection('user_lists')
                  .doc(listId)
                  .update({
                'name': listNameController.text,
                'description': listDescriptionController.text,
              });

              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      );
    },
  );
}
