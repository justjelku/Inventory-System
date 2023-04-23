import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_login_auth/model/usermodel.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  // ignore: deprecated_member_use
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference()
      .child('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "AniDB.db"),
      onCreate: (database, version) async {
        await database.execute("""
        CREATE TABLE userTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL
        )
        """);

        await database.execute("""
        CREATE TABLE adminTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL
        )
        """);
      },
      version: 1,
    );
  }

  Future<bool> insertUserData(UserModel userModel) async {
    final Database db = await initDB();
    db.insert("userTable", userModel.toMap());
    return true;
  }

  Future<bool> insertAdminData(AdminUserModel adminUserModel) async {
    final Database db = await initDB();
    db.insert("adminTable", adminUserModel.toMap());
    return true;
  }

  Future<List<UserModel>> getUserData() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> data = await db.query("userTable");
    return data.map((e) => BasicUserModel.fromUserModel(UserModel(
      uid: e['uid'] as String,
      email: e['email'] as String,
      firstName: e['firstName'] as String,
      lastName: e['lastName'] as String,
      username: e['username'] as String,
    ))).toList();
  }

  Future<List<AdminUserModel>> getAdminData() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> data = await db.query("adminTable");
    return data.map((e) => AdminUserModel.fromUserModel(UserModel(
      uid: e['uid'] as String,
      email: e['email'] as String,
      firstName: e['firstName'] as String,
      lastName: e['lastName'] as String,
      username: e['username'] as String,
    ))).toList();
  }

  Future<void> updateUser(UserModel userModel, int id) async {
    final Database db = await initDB();
    await db.update("userTable", userModel.toMap(), where: "id=?", whereArgs: [id]);
  }

  Future<void> updateAdmin(AdminUserModel adminUserModel, int id) async {
    final Database db = await initDB();
    await db.update("adminTable", adminUserModel.toMap(), where: "id=?", whereArgs: [id]);
  }

  Future<void> deleteUser(int id) async {
    final Database db = await initDB();
    await db.delete("userTable", where: "id=?", whereArgs: [id]);
  }

  Future<void> deleteAdmin(int id) async {
    final Database db = await initDB();
    await db.delete("adminTable", where: "id=?", whereArgs: [id]);
  }

  Future<void> deleteUserData(String uid) async {
    final Database db = await initDB();
    await db.delete("userTable", where: "id=?", whereArgs: [uid]);
  }


  Future<void> syncUserData() async {
    final List<UserModel> localUsersList = await getUserData();

    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      // Handle case where user is not authenticated
      return;
    }

    final DatabaseReference userRef = _userRef.child(firebaseUser.uid);

    try {
      final DataSnapshot snapshot = (await userRef.once()) as DataSnapshot;
      final Object? usersMap = snapshot.value;
      final List<UserModel> firebaseUsersList = [];

      if (usersMap is Map<String, dynamic>) {
        final List<UserModel> firebaseUsersList = [];

        usersMap.forEach((key, value) {
          final UserModel userModel = UserModel.fromMap(value);
          if (value['type'] == 'admin') {
            firebaseUsersList.add(AdminUserModel.fromUserModel(userModel));
          } else {
            firebaseUsersList.add(BasicUserModel.fromUserModel(userModel));
          }
        });
      }


      // Sync local SQLite data with Firebase data
      for (final localUser in localUsersList) {
        final matchingUsers = firebaseUsersList.where((user) => user.uid == localUser.uid);
        if (matchingUsers.isEmpty) {
          // User does not exist in Firebase, delete from SQLite
          await deleteUserData(localUser.uid);
        } else {
          final matchingUser = matchingUsers.first;
          // Update user in Firebase with local data
          final Map<String, dynamic> updateData = {
            'firstName': localUser.firstName,
            'lastName': localUser.lastName,
            'username': localUser.username,
            'email': localUser.email,
            'type': localUser is AdminUserModel ? 'admin' : 'basic',
          };
          await userRef.child(localUser.uid).update(updateData);

          // Delete updated user from local list
          firebaseUsersList.remove(matchingUser);
        }
      }


      // Add remaining Firebase users to local SQLite
      for (final firebaseUser in firebaseUsersList) {
        await insertUserData(firebaseUser);
      }
    } catch (e) {
      // Handle any exceptions that may occur
      print('Error syncing user data: $e');
    }
  }


}