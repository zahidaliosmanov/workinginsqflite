import 'dart:io';
import "dart:async";
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import "package:workinginsqflite/models/task_model.dart";

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;
  DatabaseHelper._instance();

  String tasksTable = "task_table";
  String colId = "id";
  String colTitle = "title";
  String colDate = "date";
  String colPriority = "priority";
  String colStatus = "status";

  //Task Tables
  // id | title | date | priority | Status
  // 0     ""      ""      ""         ""
  // 1     ""      ""      ""         ""

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  // Function for Initializing the database
  Future<Database> _initDb() async {
    //Getting Application directory path
    Directory dir = await getApplicationDocumentsDirectory();
    //Makin complete path string for the final database path
    String path = dir.path + "todo_list.db";
    //Opening the database in the given path, in given version and calling onCreate method for creating the table
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    //returning the Database
    return todoListDb;
  }

  //Creating the database table in the given database and version
  void _createDb(Database db, int version) async {
    //Using execute function and sql code in the string we create table with below attributes
    await db.execute(
        "CREATE TABLE $tasksTable($colId INTEGER PIRMARY KEY AUTOINCREMENT. $colTitle TEXT,$colDate TEXT, $colPriority TEXT,$colStatus INTEGER)");
  }

  //Functino for getting the table as list of maps from database
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    //getting the db
    Database db = await this.db;
    // getting the table as list of maps form database
    final List<Map<String, dynamic>> result = await db.query(tasksTable);
    //returning list of maps
    return result;
  }

  //Getting The List of Tasks form the List of Maps
  Future<List<Task>> getTaskList() async {
    //Getting List of maps from database using getTaskMapList function
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    //initializing empty List of tasks
    final List<Task> taskList = [];
    //Looping through the List of Maps , converting all the Maps data to the Task and after adding Task to the list
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    //Returning list of Tasks
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

  //Inserting new task into the database function
  Future<int> insertTask(Task task) async {
    //getting the db
    Database db = await this.db;
    //Using insert function we add task as map into the tasksTable
    final int result = await db.insert(tasksTable, task.toMap());
    //and returning 1 or 0 depending on successful or unsuccessful operation
    return result;
  }

  //updating the Task in the Database Table
  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(tasksTable, task.toMap(),
        where: "$colId = ?", whereArgs: [task.id]);
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      tasksTable,
      where: "$colId = ?",
      whereArgs: [id],
    );
    return result;
  }
}
