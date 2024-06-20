import 'package:flutter/material.dart';

class ShoppingListItemWidget extends StatelessWidget {
  final String itemName;
  final int itemQuantity;
  final bool isChecked;
  final TextEditingController itemNameController;
  final TextEditingController quantityController;
  final VoidCallback onCheckedChanged;
  final VoidCallback onDelete;
  final VoidCallback onSaveChanges;

  const ShoppingListItemWidget({
    Key? key,
    required this.itemName,
    required this.itemQuantity,
    required this.isChecked,
    required this.itemNameController,
    required this.quantityController,
    required this.onCheckedChanged,
    required this.onDelete,
    required this.onSaveChanges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onCheckedChanged();
      },
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? Colors.green : null,
          ),
          onPressed: () {
            onCheckedChanged();
          },
        ),
        title: Stack(
          children: [
            Text(
              itemName,
              style: isChecked
                  ? const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ],
        ),
        subtitle: Text('Quantity: $itemQuantity'),
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
                          controller: itemNameController,
                          decoration: InputDecoration(labelText: 'Item Name'),
                        ),
                        TextField(
                          controller: quantityController,
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
                        onPressed: onSaveChanges,
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
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
