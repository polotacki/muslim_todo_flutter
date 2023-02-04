import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled3/modules/archived_tasks/archived_tasks.dart';
import 'package:untitled3/modules/done_tasks/done_tasks.dart';
import 'package:untitled3/modules/pending_tasks/pending_tasks.dart';

part 'state.dart';

class AppCubit extends Cubit<AppStates> {
  int currentIndex = 0;
  List<Widget> screens = [
    const PendingTasks(),
    const DoneTasks(),
    const ArchivedTasks(),
  ];
  List<Icon> iconAppBar = [
    const Icon(
      Icons.list_alt_rounded,
      color: Colors.deepPurple,
      size: 35,
    ),
    const Icon(
      Icons.data_saver_off_rounded,
      color: Colors.deepPurple,
      size: 35,
    ),
    const Icon(
      Icons.archive_rounded,
      color: Colors.deepPurple,
      size: 35,
    )
  ];
  List<Map> tasks = [];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  bool check1 = false;

  List<String> titles = ['My List', 'Done Tasks', 'Archive'];
  late Database database;
  final String tableTodo = 'tasks';
  final String columnId = '_id';
  final String columnTitle = 'title';
  final String columnDate = 'date';
  final String columnTime = 'time';
  final String columnStatus = 'status';

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) async {
      print('database created');

      await database.execute('''
create table $tableTodo ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
   $columnDate text not null,
    $columnTime text not null,
  $columnStatus text not null)
''');
      print('table created');
    }, onOpen: (database) {
      getDataFromDatabase(database).then((value) {
        tasks = value;
        print("got tasks.. $tasks");
        emit(AppGetDatabaseState());
      });
      print('database opened');
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  Future insertToDatabase(
      {@required String? title,
      @required String? time,
      @required String? date}) async {
    return await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO $tableTodo ($columnTitle,$columnDate,$columnTime,$columnStatus) VALUES ("$title","$date","$time","")')
          .then((value) {
        print('id $value inserted successfully');
      }).catchError((onError) {
        print(onError.toString());
      });
      todoInsert() async {
        var x = print("inserting data ..");
        return x;
      }

      return todoInsert();
    });
  }

  Future<List<Map>> getDataFromDatabase(database) async {
    return await database.rawQuery('SELECT * FROM tasks');
  }

  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
}