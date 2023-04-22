import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/todo/todomodel.dart';
import 'package:firebase_login_auth/todo/todoprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({Key? key}) : super(key: key);

  @override
  State<AddTodo> createState() => _AddTodoState();
}
class _AddTodoState extends State<AddTodo> {

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Provider<TodoProvider>(
        create: (_) => TodoProvider(),
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Add todo'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async{
                      final title = _titleController.text.trim();
                      final description = _descriptionController.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a title.')),
                        );
                        return;
                      }
                      final todo = Todo(
                        id: '',
                        title: title,
                        description: description,
                        completed: false,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                      );

                      await TodoProvider().addTodo(todo);

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add Todo'),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}






