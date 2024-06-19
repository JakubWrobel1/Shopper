import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see your shopping list'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _itemNameController,
                        decoration:
                            const InputDecoration(labelText: 'Item Name'),
                      ),
                      TextField(
                        controller: _quantityController,
                        decoration:
                            const InputDecoration(labelText: 'Quantity'),
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
                              const SnackBar(
                                content: Text('Item name cannot be empty'),
                              ),
                            );
                          }
                        },
                        child: const Text('Add Item'),
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
                        .doc(widget.listId)
                        .collection('items')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var items = snapshot.data!.docs;

                      if (items.isEmpty) {
                        return const Center(
                            child: Text('No items in this list.'));
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
                            itemName: itemName,
                            quantity: quantity,
                            isChecked: isChecked,
                            onCheckedChanged: (bool newValue) {
                              toggleItemChecked(itemId, isChecked);
                            },
                            onDelete: () {
                              deleteItemFromShoppingList(itemId);
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
  final String itemName;
  final int quantity;
  final bool isChecked;
  final ValueChanged<bool> onCheckedChanged;
  final VoidCallback onDelete;

  ShoppingListItem({
    required this.itemName,
    required this.quantity,
    required this.isChecked,
    required this.onCheckedChanged,
    required this.onDelete,
  });

  @override
  _ShoppingListItemState createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    if (widget.isChecked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ShoppingListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            Text(widget.itemName),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: LinePainter(_animation.value),
                  child: Container(),
                );
              },
            ),
          ],
        ),
        subtitle: Text('Quantity: ${widget.quantity}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: widget.onDelete,
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double progress;

  LinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    final x2 = size.width * progress;

    canvas.drawLine(const Offset(0, 13.0), Offset(x2, 13.0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
