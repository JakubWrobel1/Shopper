import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedListId;

  void createShoppingList(String listName) async {
    User? user = _auth.currentUser;

    if (user != null) {
      var newList = await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .add({'name': listName});

      setState(() {
        _selectedListId = newList.id;
      });
    } else {
      print("User is not logged in.");
    }
  }

  void addItemToShoppingList(
      String listId, String itemName, int quantity) async {
    User? user = _auth.currentUser;

    if (user != null && listId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(listId)
          .collection('items')
          .add({
        'name': itemName,
        'quantity': quantity,
      });
    } else {
      print("User is not logged in or listId is empty.");
    }
  }

  void deleteItemFromShoppingList(String listId, String itemId) async {
    User? user = _auth.currentUser;

    if (user != null && listId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(listId)
          .collection('items')
          .doc(itemId)
          .delete();
    } else {
      print("User is not logged in or listId is empty.");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text('Please log in to see your shopping lists'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _listNameController,
                        decoration: InputDecoration(labelText: 'New List Name'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          createShoppingList(_listNameController.text);
                          _listNameController.clear();
                        },
                        child: Text('Create New List'),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('shopping_lists')
                            .doc(user.uid)
                            .collection('user_lists')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          var lists = snapshot.data!.docs;

                          if (lists.isEmpty) {
                            return Center(
                                child: Text('No shopping lists available.'));
                          }

                          return DropdownButton<String>(
                            value: _selectedListId,
                            hint: Text('Select a list'),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedListId = newValue!;
                              });
                            },
                            items: lists.map<DropdownMenuItem<String>>(
                                (DocumentSnapshot document) {
                              return DropdownMenuItem<String>(
                                value: document.id,
                                child: Text(document['name']),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _selectedListId == null
                    ? Center(child: Text('Select a list to view items'))
                    : Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _itemNameController,
                                    decoration:
                                        InputDecoration(labelText: 'Item Name'),
                                  ),
                                  TextField(
                                    controller: _quantityController,
                                    decoration:
                                        InputDecoration(labelText: 'Quantity'),
                                    keyboardType: TextInputType.number,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      addItemToShoppingList(
                                        _selectedListId!,
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
                                    .collection('user_lists')
                                    .doc(_selectedListId)
                                    .collection('items')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  var items = snapshot.data!.docs;

                                  if (items.isEmpty) {
                                    return Center(
                                        child: Text('No items in this list.'));
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
                                            deleteItemFromShoppingList(
                                                _selectedListId!, itemId);
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
                      ),
              ],
            ),
    );
  }
}
