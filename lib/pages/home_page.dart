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
  final TextEditingController _listDescriptionController =
      TextEditingController(); // Nowy kontroler dla opisu
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

  void createShoppingList(String listName, String? listDescription) async {
    User? user = _auth.currentUser;

    if (user != null) {
      Map<String, dynamic> dataToAdd = {'name': listName};
      if (listDescription != null && listDescription.isNotEmpty) {
        dataToAdd['description'] = listDescription;
      }

      await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .add(dataToAdd);

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

  void editShoppingList(
      String listId, String newName, String newDescription) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(listId)
          .update({
        'name': newName,
        'description': newDescription,
      });

      setState(() {});
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

  Future<void> _showEditDialog(
      String listId, String currentName, String? currentDescription) async {
    TextEditingController editNameController =
        TextEditingController(text: currentName);
    TextEditingController editDescriptionController =
        TextEditingController(text: currentDescription ?? '');

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: editNameController,
                decoration: const InputDecoration(labelText: 'New Name'),
              ),
              TextField(
                controller: editDescriptionController,
                decoration: const InputDecoration(
                    labelText: 'New Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                editShoppingList(listId, editNameController.text,
                    editDescriptionController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
                      // Nowe pole do wprowadzania opisu listy
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _listDescriptionController,
                          decoration: const InputDecoration(
                              labelText: 'List Description'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          createShoppingList(
                              _listNameController.text,
                              _listDescriptionController.text); // Dodanie opisu do listy
                          _listNameController.clear();
                          _listDescriptionController.clear(); // Wyczyszczenie pola opisu po dodaniu listy
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
                          var listData = list.data() as Map<String, dynamic>?;
                          var listName = listData?['name'] ?? '';
                          var listDescription = listData?['description'] ??
                              ''; // Sprawdzenie istnienia pola
                          var listId = list.id;

                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      listDescription,
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditDialog(
                                            listId, listName, listDescription);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        deleteShoppingList(listId, listName);
                                      },
                                    ),
                                  ],
                                ),
                              ],
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
