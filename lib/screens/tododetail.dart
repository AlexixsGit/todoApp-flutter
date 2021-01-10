import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/util/dbHelper.dart';

final List<String> choices = const <String>[
  'Save Todo and Back',
  'Delete Todo',
  'Back to list'
];

const mnuSave = 'Save Todo and Back';
const mnuDelete = 'Delete Todo';
const mnuBack = 'Back to list';

DbHelper dbHelper = DbHelper();

class TodoDetail extends StatefulWidget {
  final Todo todo;
  TodoDetail(this.todo);

  @override
  State<StatefulWidget> createState() => TodoDetailState(todo);
}

class TodoDetailState extends State<TodoDetail> {
  Todo todo;
  TodoDetailState(this.todo);
  final _priorities = ["High", "Medium", "Low"];
  String dropdownValue = 'Low';
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    TextStyle textStyle = Theme.of(context).textTheme.bodyText2;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(todo.title),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem(child: Text(choice), value: choice);
              }).toList();
            },
            onSelected: select,
          )
        ],
      ),
      body: Padding(
          padding: EdgeInsets.only(top: 35, left: 10, right: 10),
          child: ListView(children: [
            Column(
              children: [
                TextField(
                  onChanged: (value) => this.updateTitle(),
                  controller: titleController,
                  style: textStyle,
                  decoration: InputDecoration(
                      labelStyle: textStyle,
                      labelText: "Title",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: TextField(
                      onChanged: (value) => this.updateDescription(),
                      controller: descriptionController,
                      style: textStyle,
                      decoration: InputDecoration(
                          labelStyle: textStyle,
                          labelText: "Description",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    )),
                DropdownButton<String>(
                  value: retrievePriority(todo.priority),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (newValue) => updatePriority(newValue),
                  items:
                      _priorities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ],
            )
          ])),
    );
  }

  void select(String value) async {
    int result;

    switch (value) {
      case mnuSave:
        save();
        break;
      case mnuDelete:
        Navigator.pop(context, true);
        if (todo.id == null) {
          return;
        }
        result = await dbHelper.deleteTodo(todo.id);
        if (result != 0) {
          AlertDialog alertDialog = AlertDialog(
            title: Text('Delete todo'),
            content: Text('The todo has been deleted'),
          );
          showDialog(context: context, builder: (_) => alertDialog);
        }
        break;
      case mnuBack:
        Navigator.pop(context, true);
        break;
      default:
    }
  }

  void save() {
    todo.date = new DateFormat.yMd().format(DateTime.now());

    if (todo.id != null) {
      dbHelper.updateTodo(todo);
    } else {
      dbHelper.insertTodo(todo);
    }
    Navigator.pop(context, true);
  }

  void updatePriority(String value) {
    switch (value) {
      case 'High':
        todo.priority = 1;
        break;
      case 'Medium':
        todo.priority = 2;
        break;
      default:
        todo.priority = 3;
        break;
    }
    setState(() {
      this.dropdownValue = value;
    });
  }

  String retrievePriority(int value) {
    return _priorities[value - 1];
  }

  void updateTitle() {
    todo.title = titleController.text;
  }

  void updateDescription() {
    todo.description = descriptionController.text;
  }
}
