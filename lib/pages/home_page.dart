import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/gradient_floating_action_button.dart';
import 'shopping_list_pages/shopping_list_functions/edit_shopping_list_dialog.dart';
import 'shopping_list_pages/shopping_list_functions/create_shopping_list_function.dart';
import 'shopping_list_items/item_list_page.dart';

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
  User? user;
  String userRole = 'user'; // Default role

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      _fetchUserRole();
    }
  }

  Future<void> _fetchUserRole() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (userDoc.exists) {
      setState(() {
        userRole = userDoc['role'] ?? 'user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your shopping lists'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'account':
                  Navigator.pushNamed(context, '/account');
                  break;
                case 'admin':
                  if (userRole == 'admin') {
                    Navigator.pushNamed(context, '/admin');
                  }
                  break;
                case 'logout':
                  _auth.signOut().then((_) {
                    Navigator.pushReplacementNamed(context, '/login');
                  });
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'account',
                child: Text('Account'),
              ),
              if (userRole == 'admin')
                const PopupMenuItem<String>(
                  value: 'admin',
                  child: Text('Admin Panel'),
                ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            icon: const Icon(Icons.menu), // Menu icon
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text('Please log in to see your shopping lists'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shopping_lists')
                  .doc(user!.uid)
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
                        color: const Color.fromRGBO(35, 35, 49, 0.8),
                        border: Border.all(
                            color: const Color.fromRGBO(52, 51, 67, 1),
                            width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        title: Text(listName),
                        subtitle: listDescription.isNotEmpty
                            ? Text(listDescription)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            editShoppingList(
                              context: context,
                              auth: _auth,
                              listNameController: _listNameController,
                              listDescriptionController:
                                  _listDescriptionController,
                              listId: listId,
                              currentName: listName,
                              currentDescription: listDescription,
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShoppingListPage(listId)),
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
                        context: context,
                        auth: _auth,
                        listName: _listNameController.text,
                        listDescription: _listDescriptionController.text,
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
