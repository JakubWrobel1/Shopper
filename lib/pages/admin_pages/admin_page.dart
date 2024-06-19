import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void registerUser(String email, String password, String name) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'role': 'user',
        });
      }

      setState(() {});
    } catch (e) {
      print("Error: $e");
    }
  }

  void deleteUser(String userId) async {
    User? adminUser = _auth.currentUser;

    if (adminUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      await _auth.currentUser!
          .delete(); // Usuń użytkownika z Firebase Authentication
      setState(() {});
    } else {
      print("Admin user is not logged in.");
    }
  }

  void updateUser(
      String userId, String email, String name, String password) async {
    User? adminUser = _auth.currentUser;

    if (adminUser != null) {
      try {
        // Aktualizacja danych użytkownika w Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'email': email,
          'name': name,
        });

        // Aktualizacja danych użytkownika w Firebase Authentication
        User? user = await _auth.currentUser;
        if (user != null) {
          await user.updateEmail(email);
          await user.updatePassword(password);
        }

        setState(() {});
      } catch (e) {
        print("Error: $e");
      }
    } else {
      print("Admin user is not logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                ElevatedButton(
                  onPressed: () {
                    registerUser(_emailController.text,
                        _passwordController.text, _nameController.text);
                    _emailController.clear();
                    _passwordController.clear();
                    _nameController.clear();
                  },
                  child: Text('Register New User'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs
                    .where((user) => user['role'] != 'admin')
                    .toList(); // Filtruj administratorów

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    var userData = user.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(userData['email'] ?? 'No email'),
                      subtitle: Text(userData['name'] ?? 'No name'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _emailController.text = userData['email'] ?? '';
                              _nameController.text = userData['name'] ?? '';
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Edit User'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: _emailController,
                                        decoration:
                                            InputDecoration(labelText: 'Email'),
                                      ),
                                      TextField(
                                        controller: _nameController,
                                        decoration:
                                            InputDecoration(labelText: 'Name'),
                                      ),
                                      TextField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                            labelText: 'Password'),
                                        obscureText: true,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        updateUser(
                                            user.id,
                                            _emailController.text,
                                            _nameController.text,
                                            _passwordController.text);
                                        Navigator.of(context).pop();
                                        _emailController.clear();
                                        _passwordController.clear();
                                        _nameController.clear();
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteUser(user.id);
                            },
                          ),
                        ],
                      ),
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
