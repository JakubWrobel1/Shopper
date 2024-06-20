// shopping_list_page_state.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopper/pages/shopping_list_items/item_list_page.dart';
import 'package:shopper/pages/shopping_list_items/shopping_list_item_widget.dart';
import '../../widgets/gradient_floating_action_button.dart';
import 'shopping_items_functions/edit_item_in_shopping_list_function.dart';
import 'shopping_items_functions/add_item_to_shopping_list_function.dart';
import 'shopping_items_functions/toggle_item_checked_function.dart';
import 'shopping_items_functions/delete_item_from_shopping_list_function.dart';

class ShoppingListPageState extends State<ShoppingListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _listName = '';

  @override
  void initState() {
    super.initState();
    _getListName();
  }

  void _getListName() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot listDoc = await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(widget.listId)
          .get();

      setState(() {
        _listName = listDoc['name'];
      });
    }
  }

  void _deleteList() async {
    User? user = _auth.currentUser;

    if (user != null) {
      bool confirm = await _showConfirmationDialog(_listName);
      if (confirm) {
        await FirebaseFirestore.instance
            .collection('shopping_lists')
            .doc(user.uid)
            .collection('user_lists')
            .doc(widget.listId)
            .delete();
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _showConfirmationDialog(String listName) async {
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
                    side: BorderSide(color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // This will add the back arrow
        title: Text(_listName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteList,
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see your shopping list'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shopping_lists')
                  .doc(user.uid)
                  .collection('user_lists')
                  .doc(widget.listId)
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var items = snapshot.data!.docs;

                if (items.isEmpty) {
                  return const Center(child: Text('No items in this list.'));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];
                    var itemName = item['name'];
                    var quantity = item['quantity'];
                    var itemId = item.id;
                    var isChecked = item['isChecked'];

                    return ShoppingListItemWidget(
                      itemName: itemName,
                      itemQuantity: quantity,
                      isChecked: isChecked,
                      itemNameController: _itemNameController,
                      quantityController: _quantityController,
                      onCheckedChanged: () {
                        toggleItemChecked(
                          auth: _auth,
                          listId: widget.listId,
                          itemId: itemId,
                          isChecked: isChecked,
                        );
                      },
                      onDelete: () {
                        deleteItemFromShoppingList(
                          auth: _auth,
                          listId: widget.listId,
                          itemId: itemId,
                        );
                      },
                      onSaveChanges: () {
                        editItemInShoppingList(
                          auth: _auth,
                          listId: widget.listId,
                          itemId: itemId,
                          newName: _itemNameController.text.trim(),
                          newQuantity:
                              int.tryParse(_quantityController.text.trim()) ??
                                  1,
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: GradientFloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add Item'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: <Widget>[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      backgroundColor: Colors.grey.withOpacity(0.1),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_itemNameController.text.isNotEmpty) {
                        addItemToShoppingList(
                          auth: _auth,
                          listId: widget.listId,
                          itemName: _itemNameController.text,
                          quantity: int.tryParse(_quantityController.text) ?? 1,
                        );
                        _itemNameController.clear();
                        _quantityController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item name cannot be empty'),
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                actionsAlignment: MainAxisAlignment.center,
              );
            },
          );
        },
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
