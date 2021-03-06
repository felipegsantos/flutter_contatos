import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "id";
final String nameColumn = "name";
final String emailColumn = "email";
final String phoneColumn = "phone";
final String imageColumn = "image";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db
            .execute("CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY,"
                "$nameColumn TEXT,"
                "$emailColumn TEXT,"
                "$phoneColumn TEXT,"
                "$imageColumn TEXT)");
      },
    );
  }

  saveContact(Contact contact) async {
    Database contactDatabase = await db;
    contact.id = await contactDatabase.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database contactDatabase = await db;
    List<Map> maps = await contactDatabase.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteContact(int id) async {
    Database contactDatabase = await db;
    return await contactDatabase.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact c) async {
    Database contactDatabase = await db;
    return await contactDatabase.update(contactTable, c.toMap(), where: "$idColumn = ?", whereArgs: [c.id]);
  }

  Future<List<Contact>> getAllContacts() async {
    Database contactDatabase = await db;
    List<Map> listMap = await contactDatabase.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for(Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database contactDatabase = await db;
    return Sqflite.firstIntValue(await contactDatabase.rawQuery("SELECT count(*) from $contactTable"));
  }

  Future<void> close() async {
    Database contactDatabase = await db;
    return await contactDatabase.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image
    };
    if (id != null) map[idColumn] = id;
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, email: $email, phone: $phone, image: $image)";
  }
}
