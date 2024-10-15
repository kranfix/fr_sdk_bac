import 'dart:convert';

import 'package:fr_sdk_bac/domain/domain.dart';
import 'package:fr_sdk_bac/fr_sdk.dart';

class FRTodoRepo implements TodoRepo {
  FRTodoRepo(this.frSdk);

  final FRSdk frSdk;

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final result = await frSdk.callEndpoint(
        'https://fr-todos-api.crbrl.io/todos',
        HttpMethod.get,
        '',
        false,
      );
      //final String result = await platform.invokeMethod('callEndpoint', ["https://bacciambl.encore.forgerock.com/transfer?authType=fido",'POST', '{"srcAcct": "35679383", "destAcct": "3975273", "amount": 230.00}', "true"]);
      List<dynamic> toDosList = jsonDecode(result);
      final todos = List<Map<String, dynamic>>.from(toDosList);
      return todos.map(Todo.fromJson).toList();
    } on FRCallEndpointError catch (e) {
      throw GetTodosError(e);
    } catch (e) {
      throw GetTodosError.unexpected(e);
    }
  }

  @override
  Future<void> addTodo(String name) async {
    await frSdk.callEndpoint(
      'https://fr-todos-api.crbrl.io/todos',
      HttpMethod.post,
      '{"title": "$name"}',
      false,
    );
  }

  @override
  Future<void> deleteTodo(Todo item) async {
    try {
      await frSdk.callEndpoint(
        'https://fr-todos-api.crbrl.io/todos/${item.id}',
        HttpMethod.delete,
        '',
        false,
      );
    } on FRCallEndpointError catch (e) {
      throw GetTodosError(e);
    } catch (e) {
      throw GetTodosError.unexpected(e);
    }
  }

  @override
  Future<void> updateTodo(Todo item, bool checked) async {
    try {
      await frSdk.callEndpoint(
        'https://fr-todos-api.crbrl.io/todos/${item.id}',
        HttpMethod.post,
        '{"completed": $checked}',
        false,
      );
    } on FRCallEndpointError catch (e) {
      throw GetTodosError(e);
    } catch (e) {
      throw GetTodosError.unexpected(e);
    }
  }
}
