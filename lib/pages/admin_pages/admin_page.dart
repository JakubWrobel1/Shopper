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
  bool _passwordVisible = false; // Zmienna do kontrolowania widoczności hasła
  String _role = 'user'; // Default role

  void registerUser(
      String email, String password, String name, String role) async {
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
          'role': role,
        });
      }

      setState(() {});
    } catch (e) {
      print("Error: $e");
    }
  }

  void updateUser(String userId, String name) async {
    User? adminUser = _auth.currentUser;

    if (adminUser != null) {
      try {
        // Aktualizacja danych użytkownika w Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'name': name,
        });

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
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                DropdownButton<String>(
                  value: _role,
                  items: <String>['user', 'admin'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _role = newValue!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    registerUser(_emailController.text,
                        _passwordController.text, _nameController.text, _role);
                    _emailController.clear();
                    _passwordController.clear();
                    _nameController.clear();
                    setState(() {
                      _role = 'user'; // Reset role to default
                    });
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

                var users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    var userData = user.data() as Map<String, dynamic>;
                    var userId = user.id;

                    return ListTile(
                      title: Text(userData['email'] ?? 'No email'),
                      subtitle: Text(userData['name'] ?? 'No name'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _nameController.text = userData['name'] ?? '';
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Edit User Name'),
                              content: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(labelText: 'Name'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    updateUser(userId, _nameController.text);
                                    Navigator.of(context).pop();
                                    _nameController.clear();
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
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
