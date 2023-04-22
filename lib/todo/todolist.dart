import 'package:firebase_login_auth/todo/addtodo.dart';
import 'package:firebase_login_auth/todo/todomodel.dart';
import 'package:firebase_login_auth/todo/todoprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<List<Todo>>(
          create: (_) => [], // Initialize an empty list
        ),
        StreamProvider<List<Todo>>.value(
          value: TodoProvider().todoStream,
          initialData: [], // Use an empty list as the initial data
        ),
      ],
      child: Scaffold(
        body: Consumer<List<Todo>>(
          builder: (context, todos, child) {
            if (todos.isEmpty) {
              return const Center(
                child: Text('No todos found.'),
              );
            }
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: Checkbox(
                    value: todo.completed,
                    onChanged: (value) {
                      final updatedTodo = todo.copyWith(completed: value!);
                      TodoProvider().updateTodo(updatedTodo);
                    },
                  ),
                  onLongPress: () {
                    TodoProvider().deleteTodo(todo.id);
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AddTodo(),
            ));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );

  }
}




