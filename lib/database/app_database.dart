
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/patient.dart';
import '../models/specimen.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;


  Future<void> insertSpecimen(Specimen specimen) async {
    final db = await database;
    await db.insert(
      'specimens',
      specimen.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Specimen>> getSpecimens() async {
    final db = await database;
    final rows = await db.query(
      'specimens',
      orderBy: 'created_at DESC',
    );
    return rows.map(Specimen.fromMap).toList();
  }

  Future<int> countPendingSpecimens() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) FROM specimens WHERE sync_status = 'pending'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }


  Future<Database> get database async {
    if (_database != null) return _database!;

    final path = join(
      await getDatabasesPath(),
      'measles_surveillance.db',
    );


    _database = await openDatabase(
      path,
      version: 3,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        first_name TEXT NOT NULL,
        surname TEXT NOT NULL,
        national_id TEXT NOT NULL DEFAULT '',
        sex TEXT NOT NULL,
        date_of_birth TEXT NOT NULL DEFAULT '',
        phone TEXT NOT NULL DEFAULT '',
        village TEXT NOT NULL DEFAULT '',
        org_unit TEXT NOT NULL DEFAULT '',
        sync_status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL
      )
    ''');

        await createSpecimensTable(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await createSpecimensTable(db);
        }
      },
    );



    return _database!;
  }

  Future<void> insertPatient(Patient patient) async {
    final db = await database;

    await db.insert(
      'patients',
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Patient>> getPatients() async {
    final db = await database;

    final rows = await db.query(
      'patients',
      orderBy: 'created_at DESC',
    );

    return rows.map(Patient.fromMap).toList();
  }

  Future<int> countPatients() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM patients',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countPendingPatients() async {
    final db = await database;

    final result = await db.rawQuery(
      "SELECT COUNT(*) AS total FROM patients WHERE sync_status = 'pending'",
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }



  Future<void> createSpecimensTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS specimens (
      id TEXT PRIMARY KEY,
      specimen_id TEXT NOT NULL,
      patient_local_id TEXT NOT NULL,
      sample_type TEXT NOT NULL,
      collected_at TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL,
      FOREIGN KEY(patient_local_id)
        REFERENCES patients(id)
    )
  ''');
  }

  Future<List<Specimen>> getSpecimensForPatient(String patientId) async {
    final db = await database;

    final rows = await db.query(
      'specimens',
      where: 'patient_local_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );

    return rows.map(Specimen.fromMap).toList();
  }



}
