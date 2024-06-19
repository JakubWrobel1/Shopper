import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './shopping_list_pages/shopping_list_page.dart';
import './admin_pages/admin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _listNameController = TextEditingController();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  void _checkAdminRole() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        isAdmin = userDoc['role'] == 'admin';
      });
    }
  }

  void createShoppingList(String listName) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .add({'name': listName});

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

  Future<bool> _showConfirmationDialog(String listName) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content:
                  Text('Are you sure you want to delete the list "$listName"?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                ),
              ],
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
        automaticallyImplyLeading: false, // Usunięcie przycisku powrotu
        title: Image.asset(
          'assets/images/logo.png', // Ścieżka do logo
          height: 60, // Ustawienie wysokości logo
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminPage(),
                  ),
                );
              },
            ),
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
          ? const Center(
              child: Text('Please log in to see your shopping lists'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _listNameController,
                          decoration:
                              const InputDecoration(labelText: 'New List Name'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          createShoppingList(_listNameController.text);
                          _listNameController.clear();
                        },
                        child: const Text('Create New List'),
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

                          return ListTile(
                            title: Text(listName),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteShoppingList(listId, listName);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShoppingListPage(listId),
                                ),
                              );
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
