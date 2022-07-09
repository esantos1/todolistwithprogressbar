import 'package:flutter/material.dart';
import 'package:todolistwithprogressbar/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List todoList = [];
  final todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: Builder(
        builder: (context) => Column(
          children: [
            buildForm(),
            Expanded(
              child: buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildForm() => Container(
        padding: EdgeInsets.fromLTRB(defaultPadding, 8.0, defaultPadding, 24.0),
        child: Row(
          children: [
            Expanded(child: TextField(controller: todoController)),
            SizedBox(width: defaultPadding),
            SizedBox.square(
              dimension: 45.0,
              child: FloatingActionButton(
                onPressed: addClicked,
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      );

  void addClicked() {
    if (todoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vazio')),
      );
    }
  }

  Widget buildList() => ListView.builder(
        padding: EdgeInsets.fromLTRB(
          defaultPadding,
          4.0,
          defaultPadding,
          defaultPadding,
        ),
        itemCount: 25,
        itemBuilder: (context, index) {
          return Card(child: ListTile(title: Text('Index $index')));
        },
      );
}
