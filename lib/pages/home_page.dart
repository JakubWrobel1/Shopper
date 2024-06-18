import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  void addItemToShoppingList(String itemName, int quantity) async {
    User? user = _auth.currentUser;

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

  void deleteItemFromShoppingList(String itemId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('items')
          .doc(itemId)
          .delete();
    } else {
      print("User is not logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text('Please log in to see your shopping list'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _itemNameController,
                        decoration: InputDecoration(labelText: 'Item Name'),
                      ),
                      TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          addItemToShoppingList(
                            _itemNameController.text,
                            int.parse(_quantityController.text),
                          );
                          _itemNameController.clear();
                          _quantityController.clear();
                        },
                        child: Text('Add Item'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('shopping_lists')
                        .doc(user.uid)
                        .collection('items')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var items = snapshot.data!.docs;

                      if (items.isEmpty) {
                        return Center(
                            child: Text('No items in your shopping list.'));
                      }

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var item = items[index];
                          var itemName = item['name'];
                          var quantity = item['quantity'];
                          var itemId = item.id;

                          return ListTile(
                            title: Text(itemName),
                            subtitle: Text('Quantity: $quantity'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                deleteItemFromShoppingList(itemId);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
