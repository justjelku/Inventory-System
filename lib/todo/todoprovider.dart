import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/todo/todomodel.dart';

class TodoProvider {
  final CollectionReference todos =
  FirebaseFirestore.instance.collection('todos');

  Stream<List<Todo>> get todoStream {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    return getTodos(userId);
  }


  Future<void> addTodo(Todo todo) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoCollection = userRef.collection('todos');

    final todoData = {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'completed': todo.completed,
      'userId': todo.userId,
    };

    await todoCollection.add(todoData);
  }

  Future<void> updateTodo(Todo todo) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoCollection = userRef.collection('todos');

    final todoData = {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'completed': todo.completed,
      'userId': todo.userId,
    };

    await todoCollection.doc(todo.id).update(todoData);
  }

  Stream<List<Todo>> getTodos(String userId) {
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(userId);

    final todoCollection = userRef.collection('todos');

    return todoCollection.snapshots().map((querySnapshot) => querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Todo(
        id: doc.id,
        title: data['title'],
        description: data['description'],
        completed: data['completed'],
        userId: data['userId'],
      );
    }).toList());
  }

  Future<void> deleteTodo(String todoId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoRef = userRef.collection('todos').doc(todoId);
    await todoRef.delete();
  }

}
