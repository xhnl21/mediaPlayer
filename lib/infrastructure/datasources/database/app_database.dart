import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('FavoriteTrackEntry')
class FavoritesTable extends Table {
  @override
  String get tableName => 'favorites';

  /// Mandatory UUID primary key for every record
  TextColumn get id => text()();
  TextColumn get trackId => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get album => text().withDefault(const Constant(''))();
  IntColumn get durationMs => integer()();
  TextColumn get audioUrl => text().withDefault(const Constant(''))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [FavoritesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'media_player_app.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
