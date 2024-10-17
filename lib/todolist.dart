import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fr_sdk_bac/providers.dart';

import 'domain/domain.dart';

class TodoList extends ConsumerStatefulWidget {
  const TodoList({super.key});

  @override
  ConsumerState<TodoList> createState() => _TodoListState();
}

class TodoItem extends StatelessWidget {
  TodoItem({
    required this.todo,
    required this.onTodoChanged,
  }) : super(key: ObjectKey(todo));

  final Todo todo;
  final void Function(Todo) onTodoChanged;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: CircleAvatar(
        child: Text(todo.name[0]),
      ),
      title: Text(todo.name, style: _getTextStyle(todo.checked)),
    );
  }
}

class _TodoListState extends ConsumerState<TodoList> {
  final TextEditingController _textFieldController = TextEditingController();
  var _todos = <Todo>[];
  final List<Widget> _widgets = <Widget>[];
  static const platform = MethodChannel('forgerock.com/SampleBridge');
  String header = "";
  String subtitle = "";

  //Lifecycle methods
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      //Calling the userinfo endpoint is going to give use some user profile information to enrich our UI. Additionally, verifies that we have a valid access token.
      _getUserInfo();
    });
  }

  TodoRepo getTodoRepo() {
    return ref.read(todoRepoProvider);
  }

  // SDK Calls -  Note the promise type responses. Handle errors on the UI layer as required
  Future<void> _getUserInfo() async {
    showAlertDialog(context);
    String response;
    try {
      final String result = await platform.invokeMethod('getUserInfo');
      Map<String, dynamic> userInfoMap = jsonDecode(result);
      response = result;
      header = userInfoMap["name"];
      subtitle = userInfoMap["email"];
      if (mounted) Navigator.pop(context);
      setState(() {
        _getTodos();
      });
    } on PlatformException catch (e) {
      response = "SDK Start Failed: '${e.message}'.";
      if (mounted) Navigator.pop(context);
    }
    debugPrint('SDK: $response');
  }

  Future<void> _logout() async {
    final sdk = ref.read(frSdkProvider);
    await sdk.logout();
    if (mounted) _navigateToNextScreen(context);
  }

  //Network Calls
  Future<void> _deleteTodo(Todo todo) async {
    try {
      await getTodoRepo().deleteTodo(todo);
      _getTodos();
    } on PlatformException catch (e) {
      debugPrint('SDK: $e');
    }
  }

  Future<void> _updateTodo(Todo todo, bool checked) async {
    try {
      await getTodoRepo().updateTodo(todo, checked);
      _getTodos();
    } on PlatformException catch (e) {
      debugPrint('SDK: $e');
    }
  }

  Future<void> _getTodos() async {
    try {
      final todos = await getTodoRepo().getTodos();
      if (mounted) {
        setState(() {
          _todos = todos;
        });
      }
      debugPrint('SDK: $todos');
    } on PlatformException catch (e) {
      debugPrint('SDK: $e');
    }
  }

  Future<void> _addTodoItem(String name) async {
    try {
      await getTodoRepo().addTodo(name);
      _getTodos();
    } on PlatformException catch (e) {
      debugPrint('SDK: $e');
    }
    _textFieldController.clear();
  }

  //Helper funtions
  void _goHome() {
    Navigator.pop(context);
  }

  void _navigateToNextScreen(BuildContext context) {
    _goHome();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _logoutDialog();
    }
  }

  void showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: const Text("Loading"),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => alert,
    );
  }

  void _handleTodoChange(Todo todo) {
    final index = _todos.indexWhere((it) => todo.id == it.id);
    if (index != -1) {
      setState(() {
        _todos[index] = todo;
      });
    }
    _updateTodo(todo, todo.checked);
  }

  //Widgets

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Todo list',
          style: TextStyle(color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey[200],
      ),
      bottomNavigationBar: _bottomBar(),
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeText(),
          _listView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _logoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you want to Log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _welcomeText() {
    return Container(
      color: Colors.greenAccent[100],
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(15.0),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gpp_good),
                const SizedBox(width: 2),
                Expanded(
                  flex: 4,
                  child: Text(
                    "Welcome back, $header",
                    style: TextStyle(
                        color: Colors.grey[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 28),
                Expanded(
                    flex: 4,
                    child: Text(
                      "You're currently logged in with the email $subtitle",
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontWeight: FontWeight.w200,
                          fontSize: 14),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        for (final todo in _todos)
          Dismissible(
            key: Key(todo.id),
            onDismissed: (direction) {
              _deleteTodo(todo);
            },
            background: Container(color: Colors.red),
            child: TodoItem(
              todo: todo,
              onTodoChanged: _handleTodoChange,
            ),
          )
      ],
    );
  }

  Widget _bottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.grey[200],
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.done_all),
          label: 'To-Dos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Log out',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.blueAccent[800],
      onTap: _onItemTapped,
    );
  }

// Other functions
  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) => AlertDialog(
        title: const Text('Add a new todo item'),
        content: TextField(
          controller: _textFieldController,
          decoration: const InputDecoration(hintText: 'Type your new todo'),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              Navigator.of(context).pop();
              _addTodoItem(_textFieldController.text);
            },
          ),
        ],
      ),
    );
  }
}
