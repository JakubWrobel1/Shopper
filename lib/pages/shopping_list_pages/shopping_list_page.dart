import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopper/pallete.dart'; // Import Pallete file

class ShoppingListPage extends StatefulWidget {
  final String listId;

  const ShoppingListPage(this.listId, {super.key});

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
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
      debugPrint("User is not logged in or item name is empty.");
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
      debugPrint("User is not logged in.");
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
      debugPrint("User is not logged in.");
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
        Navigator.of(context).pop(); // Return to previous screen
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
                        editItemInShoppingList(itemId, newName, newQuantity);
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
                          _itemNameController.text,
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
                        onPressed: _saveChanges,
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

class GradientFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GradientFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Pallete.gradient1,
            Pallete.gradient2,
            Pallete.gradient3,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: child,
      ),
    );
  }
}
