import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingListPage extends StatefulWidget {
  final String listId;

  ShoppingListPage(this.listId);

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  void addItemToShoppingList(String itemName, {int quantity = 1}) async {
    User? user = _auth.currentUser;

    if (user != null && itemName.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(widget.listId)
          .collection('items')
          .add({
        'name': itemName,
        'quantity': quantity,
        'isChecked': false,
      });
    } else {
      print("User is not logged in or item name is empty.");
    }
  }

  void deleteItemFromShoppingList(String itemId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(widget.listId)
          .collection('items')
          .doc(itemId)
          .delete();
    } else {
      print("User is not logged in.");
    }
  }

  void toggleItemChecked(String itemId, bool isChecked) async {
    User? user = _auth.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(widget.listId)
          .collection('items')
          .doc(itemId)
          .update({
        'isChecked': !isChecked,
      });
    } else {
      print("User is not logged in.");
    }
  }

  void editItemInShoppingList(
      String itemId, String newName, int newQuantity) async {
    User? user = _auth.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(widget.listId)
          .collection('items')
          .doc(itemId)
          .update({
        'name': newName,
        'quantity': newQuantity,
      });
    } else {
      print("User is not logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
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
                          if (_itemNameController.text.isNotEmpty) {
                            addItemToShoppingList(
                              _itemNameController.text,
                              quantity:
                                  int.tryParse(_quantityController.text) ?? 1,
                            );
                            _itemNameController.clear();
                            _quantityController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Item name cannot be empty'),
                              ),
                            );
                          }
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
                        .doc(user!.uid)
                        .collection('user_lists')
                        .doc(widget.listId)
                        .collection('items')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var items = snapshot.data!.docs;

                      if (items.isEmpty) {
                        return Center(child: Text('No items in this list.'));
                      }

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var item = items[index];
                          var itemName = item['name'];
                          var quantity = item['quantity'];
                          var itemId = item.id;
                          var isChecked = item['isChecked'];

                          return ShoppingListItem(
                            itemId: itemId,
                            initialItemName: itemName,
                            initialQuantity: quantity,
                            isChecked: isChecked,
                            onCheckedChanged: (bool newValue) {
                              toggleItemChecked(itemId, isChecked);
                            },
                            onDelete: () {
                              deleteItemFromShoppingList(itemId);
                            },
                            onEdit: (String newName, int newQuantity) {
                              editItemInShoppingList(
                                  itemId, newName, newQuantity);
                            },
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

class ShoppingListItem extends StatefulWidget {
  final String itemId;
  final String initialItemName;
  final int initialQuantity;
  final bool isChecked;
  final ValueChanged<bool> onCheckedChanged;
  final VoidCallback onDelete;
  final Function(String newName, int newQuantity) onEdit;

  ShoppingListItem({
    required this.itemId,
    required this.initialItemName,
    required this.initialQuantity,
    required this.isChecked,
    required this.onCheckedChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _ShoppingListItemState createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem> {
  late TextEditingController _itemNameController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.initialItemName);
    _quantityController =
        TextEditingController(text: widget.initialQuantity.toString());
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    String newName = _itemNameController.text.trim();
    int newQuantity = int.tryParse(_quantityController.text.trim()) ?? 1;

    widget.onEdit(newName, newQuantity);

    Navigator.of(context).pop(); // Powrót do poprzedniego ekranu
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onCheckedChanged(!widget.isChecked);
      },
      child: ListTile(
        title: Stack(
          children: [
            Text(widget.initialItemName),
          ],
        ),
        subtitle: Text('Quantity: ${widget.initialQuantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Edit Item'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
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
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: _saveChanges,
                        child: Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
