import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './shopping_list_pages/shopping_list_page.dart'; // Upewnij się, że ten import jest poprawny
import '../pallete.dart'; // Import Pallete file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _listDescriptionController =
      TextEditingController();

  void createShoppingList(String listName, String? listDescription) async {
    User? user = _auth.currentUser;

    if (user != null) {
      if (listName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('List name cannot be empty')),
        );
        return;
      }

      Map<String, dynamic> listData = {
        'name': listName,
        'description': listDescription ?? '',
      };

      await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .add(listData);

      setState(() {});
    } else {
      debugPrint("User is not logged in.");
    }
  }

  void deleteShoppingList(String listId, String listName) async {
    User? user = _auth.currentUser;

    if (user != null) {
      bool confirm = await _showConfirmationDialog(listName);
      if (confirm) {
        await FirebaseFirestore.instance
            .collection('shopping_lists')
            .doc(user.uid)
            .collection('user_lists')
            .doc(listId)
            .delete();

        setState(() {});
      }
    } else {
      debugPrint("User is not logged in.");
    }
  }

  Future<void> editShoppingList(
      String listId, String currentName, String currentDescription) async {
    _listNameController.text = currentName;
    _listDescriptionController.text = currentDescription;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Shopping List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _listNameController,
                decoration: const InputDecoration(labelText: 'List Name'),
              ),
              TextField(
                controller: _listDescriptionController,
                decoration:
                    const InputDecoration(labelText: 'List Description'),
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
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('shopping_lists')
                    .doc(_auth.currentUser!.uid)
                    .collection('user_lists')
                    .doc(listId)
                    .update({
                  'name': _listNameController.text,
                  'description': _listDescriptionController.text,
                });

                setState(() {});
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
        title: Text('Your shopping lists'),
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
          ? const Center(
              child: Text('Please log in to see your shopping lists'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shopping_lists')
                  .doc(user.uid)
                  .collection('user_lists')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var lists = snapshot.data!.docs;

                if (lists.isEmpty) {
                  return const Center(
                      child: Text('No shopping lists available.'));
                }

                return ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    var list = lists[index];
                    var listName = list['name'];
                    var listId = list.id;
                    var listDescription = list['description'] ?? '';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(
                            35, 35, 49, 0.8), // Background color
                        border: Border.all(
                            color: const Color.fromRGBO(52, 51, 67, 1),
                            width: 2.0), // Border color and width
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        title: Text(listName),
                        subtitle: listDescription.isNotEmpty
                            ? Text(listDescription)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                editShoppingList(
                                  listId,
                                  listName,
                                  listDescription,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteShoppingList(listId, listName);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShoppingListPage(listId),
                            ),
                          );
                        },
                      ),
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
                title: const Text('Create a new list'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _listNameController,
                      decoration: const InputDecoration(labelText: 'New list'),
                    ),
                    TextField(
                      controller: _listDescriptionController,
                      decoration:
                          const InputDecoration(labelText: 'List description'),
                    ),
                  ],
                ),
                actions: <Widget>[
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
                    onPressed: () {
                      if (_listNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('List name cannot be empty'),
                          ),
                        );
                        return;
                      }
                      createShoppingList(
                        _listNameController.text,
                        _listDescriptionController.text,
                      );
                      _listNameController.clear();
                      _listDescriptionController.clear();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                actionsAlignment: MainAxisAlignment.center,
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
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
