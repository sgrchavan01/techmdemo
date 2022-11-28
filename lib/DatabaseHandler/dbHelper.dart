import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:techmdemo/Model/todomodel.dart';
import 'dart:io' as io;

import '../Model/usermodel.dart';

class DbHelper {
  static Database? _db;

  static const String DB_Name = 'main.db';
  static const String Table_User = 'user';
  static const int Version = 1;

  static const String C_UserID = 'user_id';
  static const String C_UserName = 'user_name';
  static const String C_Email = 'email';
  static const String C_Password = 'password';

  static const String Table_Todo = 'todo_table';
  static const String C_TodoId = 'id';
  static const String C_TodoTitle = 'title';
  static const String C_TodoDescription = 'description';
  static const String C_TodoDate = 'date';
  static const String C_TodoUserID = 'userId';
  static const String C_TodoImage = 'image';

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);
    var db = await openDatabase(path, version: Version, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int intVersion) async {
    await db.execute('''
      create table $Table_User (
        $C_UserID integer primary key autoincrement,
        $C_UserName text not null,
        $C_Email text not null,
        $C_Password text not null
       )''');

    await db.execute(
        'CREATE TABLE $Table_Todo($C_TodoId INTEGER PRIMARY KEY AUTOINCREMENT, $C_TodoTitle TEXT, '
        '$C_TodoDescription TEXT, $C_TodoDate TEXT,$C_TodoUserID TEXT,$C_TodoImage TEXT)');
  }

  Future<int?> saveData(UserModel user) async {
    var dbClient = await db;
    var res1 = await dbClient!.rawQuery("SELECT * FROM $Table_User WHERE ""$C_Email = '${user.email}' ");
    if (res1.length == 0) {
      var res = await dbClient!.insert(Table_User, user.toMap());
      return res;
    }
    return null;
  }

  Future<UserModel?> getLoginUser(String email, String password) async {
    var dbClient = await db;
    var res = await dbClient!.rawQuery("SELECT * FROM $Table_User WHERE "
        "$C_Email = '$email' AND "
        "$C_Password = '$password'");

    if (res.length > 0) {
      return UserModel.from(res.first);
    }

    return null;
  }

  Future<int> updateUser(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient!.update(Table_User, user.toMap(),
        where: '$C_UserID = ?', whereArgs: [user.user_id]);
    return res;
  }

  Future<int> deleteUser(String user_id) async {
    var dbClient = await db;
    var res = await dbClient!
        .delete(Table_User, where: '$C_UserID = ?', whereArgs: [user_id]);
    return res;
  }

  Future<List<Map<String, dynamic>>> getTodoMapList(String userId) async {
    var dbClient = await db;
    var result = await dbClient!.rawQuery("SELECT * FROM $Table_Todo WHERE "
        "$C_TodoUserID = '$userId'""ORDER BY $C_TodoId DESC");
    print(result);
    return result;
  }

  Future<int> insertTodo(TodoModel todo) async {
    var dbClient = await db;
    var result = await dbClient!.insert(Table_Todo, todo.toMap());
    return result;
  }


  Future<int> updateTodo(TodoModel todo) async {
    var dbClient = await db;
    var result = dbClient!.update(Table_Todo, todo.toMap(),
        where: '$C_TodoId = ?', whereArgs: [todo.id]);
    return result;
  }

  Future<int> updateTodoCompleted(TodoModel todo) async {
    var dbClient = await db;
    var result = dbClient!.update(Table_Todo, todo.toMap(),
        where: '$C_TodoId = ?', whereArgs: [todo.id]);
    return result;
  }


  Future<int> deleteTodo(int id) async {
    var dbClient = await db;
    var res = await dbClient!
        .delete(Table_Todo, where: '$C_TodoId = ?', whereArgs: [id]);
    return res;
  }


  Future<List<TodoModel>> getTodoList(String userId) async {
    var todoMapList = await getTodoMapList(userId);
    int count = todoMapList.length;

    List<TodoModel> todoList = <TodoModel>[];
    for (int i = 0; i < count; i++) {
      todoList.add(TodoModel.from(todoMapList[i]));
    }

    return todoList;
  }
}
