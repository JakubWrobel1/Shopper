import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void addItemToShoppingList(String itemName, int quantity) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(user.uid)
        .collection('items')
        .add({
      'name': itemName,
      'quantity': quantity,
    });
  } else {
    print("User is not logged in.");
  }
}
