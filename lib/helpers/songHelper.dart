import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


final String songTable = "songTable";
final String idColumn = "idColumn";
final String ytIdColumn = "ytIdColumn";
final String nomeColumn = "nomeColumn";
final String artistaColumn = "artistaColumn";
final String urlColumn = "urlColumn";
final String thumbColumn = "thumbColumn";

class SongHelper{

  static final SongHelper _instance = SongHelper.internal();

  factory SongHelper() => _instance;

  SongHelper.internal();

  Database _db;

  Future<Database> get db async{
    if(_db != null){
      return _db;
    }else{
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async{
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "data.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async{
      await db.execute(
        "CREATE TABLE $songTable ($idColumn INTEGER PRIMARY KEY,$ytIdColumn TEXT, $nomeColumn TEXT, $artistaColumn TEXT, $urlColumn TEXT, $thumbColumn TEXT)"
      );
    });
  }


  Future<Song> saveSong(Song song) async{
    Database dbSong = await db;
    song.id = await dbSong.insert(songTable, song.toMap());
    return song;
  }

  Future<Song> getSong(int id) async{
    Database dbSong = await db;
    List<Map> maps = await dbSong.query(songTable,
      columns: [idColumn, ytIdColumn, nomeColumn, artistaColumn, urlColumn, thumbColumn],
      where: "$idColumn = ?",
      whereArgs: [id]
    );

    if(maps.length > 0){
      return Song.fromMap(maps.first);
    }else{
      return null;
    }

  }

  Future<int> deleteSong(int id) async{
    Database dbSong = await db;
    return await dbSong.delete(songTable,
      where: "$idColumn = ?",
      whereArgs: [id]
    );
  }

  Future<int> updateSong(Song song) async{
    Database dbSong = await db;
    return await dbSong.update(songTable,
      song.toMap(),
      where: ("$idColumn = ?"),
      whereArgs: [song.id]
    );
  }

  Future<List> getAllSongs() async{
    Database dbSong = await db;
    List maps = await dbSong.rawQuery("SELECT * FROM $songTable");
    List<Song> songList = List();

    for(Map m in maps){
      songList.add(Song.fromMap(m));
    }

    return songList;
  }
  
  Future<int> numSongs() async{
    Database dbSong = await db;
    return Sqflite.firstIntValue(await dbSong.rawQuery("SELECT COUNT(*) FROM $songTable"));
  }

  Future close() async{
    Database dbSong = await db;
    await dbSong.close();
  }

}

class Song{
  int id;
  String ytId;
  String nome;
  String artista;
  String url;
  String thumb;

  Song();

  Song.fromMap(Map map){
    id = map[idColumn];
    ytId = map[ytIdColumn];
    nome = map[nomeColumn];
    artista = map[artistaColumn];
    url = map[urlColumn];
    thumb = map[thumbColumn];
  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      ytIdColumn: ytId,
      nomeColumn: nome,
      artistaColumn: artista,
      urlColumn: url,
      thumbColumn: thumb
    };

    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    print("Nome: $nome, ytId: $ytId, Artista: $artista, Url: $url, Thumb: $thumb");
  }

}