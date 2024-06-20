import 'package:flutter/material.dart';
import 'shopping_list_page_state.dart';

class ShoppingListPage extends StatefulWidget {
  final String listId;

  const ShoppingListPage(this.listId, {super.key});

  @override
  ShoppingListPageState createState() => ShoppingListPageState();
}
