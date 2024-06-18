import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './shopping_list_pages/shopping_list_page.dart';
import './admin_pages/admin_page.dart';

class HomePage extends StatefulWidget {
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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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
      print("User is not logged in.");
    }
  }

  void deleteShoppingList(String listId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(user.uid)
          .collection('user_lists')
          .doc(listId)
          .delete();

      setState(() {});
    } else {
      print("User is not logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.admin_panel_settings),
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
            icon: Icon(Icons.logout),
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
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('shopping_lists')
                        .doc(user!.uid)
                        .collection('user_lists')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var lists = snapshot.data!.docs;

                      if (lists.isEmpty) {
                        return Center(child: Text('No shopping lists available.'));
                      }

                      return ListView.builder(
                        itemCount: lists.length,
                        itemBuilder: (context, index) {
                          var list = lists[index];
                          return ListTile(
                            title: Text(list['name']),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                deleteShoppingList(list.id);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShoppingListPage(list.id),
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
