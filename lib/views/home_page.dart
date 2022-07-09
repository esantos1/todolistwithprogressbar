import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todolistwithprogressbar/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List todoList;
  final todoController = TextEditingController();
  late int indexLastRemoved;
  late Map<String, dynamic> lastRemoved;

  @override
  void initState() {
    super.initState();

    readData().then((value) {
      setState(() => todoList = jsonDecode(value!));
    });
  }

  Future<String?> readData() async {
    try {
      final file = await openFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  void addTask() {
    setState(() {
      Map<String, dynamic> newTask = {};

      newTask['title'] = todoController.text;
      newTask['done'] = false;

      todoController.clear();

      todoList.add(newTask);

      saveData();
    });
  }

  Future<File> saveData() async {
    String data = json.encode(todoList);
    final file = await openFile();

    return file.writeAsString(data);
  }

  Future<File> openFile() async {
    final appPath = await getApplicationDocumentsDirectory();

    return File("${appPath.path}/todoList.json");
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
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
        ),
      );

  Widget buildForm() => Container(
        padding: EdgeInsets.fromLTRB(defaultPadding, 8.0, defaultPadding, 24.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: todoController,
                maxLength: 40,
                decoration: InputDecoration(labelText: 'Nova tarefa'),
              ),
            ),
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
      showCustomSnackBar(
        context: context,
        title: 'Insira uma tarefa para adicionar',
        snackBarActionLabel: 'Ok',
        onSnackBarActionClicked: () =>
            ScaffoldMessenger.of(context).removeCurrentSnackBar(),
      );
    } else {
      addTask();
    }
  }

  Widget buildList() => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: 4.0,
            bottom: defaultPadding,
          ),
          itemCount: todoList.length,
          itemBuilder: (context, index) {
            final item = todoList[index];

            return buildTask(context, index, item);
          },
        ),
      );

  Future<void> onRefresh() async {}

  Widget buildTask(BuildContext context, int index, dynamic item) =>
      Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(0.85, 0.0),
            child: Icon(Icons.delete_sweep, color: Colors.white),
          ),
        ),
        direction: DismissDirection.endToStart,
        child: buildWidget(item),
        onDismissed: (dismissed) {
          setState(() {
            lastRemoved = Map.from(item);
            indexLastRemoved = index;

            todoList.removeAt(index);

            saveData();

            showCustomSnackBar(
              context: context,
              title: 'A tarefa "${lastRemoved['title']}" foi excluída',
              snackBarActionLabel: 'Desfazer',
              onSnackBarActionClicked: () {
                setState(() {
                  todoList.insert(indexLastRemoved, lastRemoved);
                  saveData();
                });
              },
            );
          });
        },
      );

  Widget buildWidget(dynamic item) => CheckboxListTile(
        value: item['done'],
        secondary: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            item['done'] ? Icons.check : Icons.error,
            color: Colors.white,
          ),
        ),
        title: Text(item['title']),
        onChanged: (value) {
          setState(() {
            item['done'] = value;
            saveData();
          });
        },
      );
}
