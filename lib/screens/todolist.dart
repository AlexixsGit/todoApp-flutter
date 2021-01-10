import 'package:flutter/material.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/screens/tododetail.dart';
import 'package:todo_app/util/dbHelper.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State {
  DbHelper dbHelper = DbHelper();
  List<Todo> todos = List<Todo>();
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (todos == null || todos.length == 0) {
      todos = List<Todo>();
      loadData();
    }
    return Scaffold(
      body: todoListItems(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateDetail(Todo('', 3, ''));
        },
        tooltip: "Add new todo",
        child: new Icon(Icons.add),
      ),
    );
  }

  ListView todoListItems() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getColor(this.todos[position].priority),
                child: Text(this.todos[position].priority.toString()),
              ),
              title: Text(this.todos[position].title),
              subtitle: Text(this.todos[position].date),
              onTap: () => navigateDetail(this.todos[position]),
            ),
          );
        });
  }

  void loadData() {
    final dbFuture = dbHelper.initializeDb();
    dbFuture.then((db) {
      final todosFuture = dbHelper.getTodos();
      todosFuture.then((todoItems) {
        List<Todo> todoList = List<Todo>();
        count = todoItems.length;

        todoItems.toList().forEach((element) {
          todoList.add(Todo.fromObject(element));
          print(todoList);
        });

        setState(() {
          this.todos = todoList;
          this.count = count;
        });
        debugPrint("Items $count");
      });
    });
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.green;
    }
  }

  void navigateDetail(Todo todo) async {
    bool result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TodoDetail(todo)));

    if (result) {
      loadData();
    }
  }
}
