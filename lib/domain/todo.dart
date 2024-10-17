abstract class TodoRepo {
  Future<List<Todo>> getTodos();
  Future<void> addTodo(String name);
  Future<void> deleteTodo(Todo item);
  Future<void> updateTodo(Todo item, bool checked);
}

class Todo {
  Todo({required this.name, required this.id, required this.checked});

  final String name;
  final String id;
  final bool checked;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["_id"],
      name: json["title"],
      checked: json["completed"],
    );
  }
}

class GetTodosError implements Exception {
  GetTodosError(Exception this.exception) : unexpected = null;
  GetTodosError.unexpected(this.unexpected) : exception = null;

  final Exception? exception;
  final Object? unexpected;
}

class DeleteTodoError implements Exception {
  DeleteTodoError(Exception this.exception) : unexpected = null;
  DeleteTodoError.unexpected(this.unexpected) : exception = null;

  final Exception? exception;
  final Object? unexpected;
}

class UpdateTodoError implements Exception {
  UpdateTodoError(Exception this.exception) : unexpected = null;
  UpdateTodoError.unexpected(this.unexpected) : exception = null;

  final Exception? exception;
  final Object? unexpected;
}
