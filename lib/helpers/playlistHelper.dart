import 'package:fuck_spotify/helpers/songHelper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


final String playlistTable = "playlistTable";
final String idColumn = "idColumn";
final String nomeColumn = "nomeColumn";
final String descColumn = "descColumn";
final String songColumn = "songColumn";

class PlaylistHelper{

  static final PlaylistHelper _instance = PlaylistHelper.internal();

  factory PlaylistHelper() => _instance;

  PlaylistHelper.internal();

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
          "CREATE TABLE $playlistTable ($idColumn INTEGER PRIMARY KEY,$ytIdColumn TEXT, $nomeColumn TEXT, $artistaColumn TEXT, $urlColumn TEXT, $thumbColumn TEXT)"
      );
    });
  }


  Future<Playlist> savePlaylist(Playlist Playlist) async{
    Database dbPlaylist = await db;
    Playlist.id = await dbPlaylist.insert(playlistTable, Playlist.toMap());
    return Playlist;
  }

  Future<Playlist> getPlaylist(int id) async{
    Database dbPlaylist = await db;
    List<Map> maps = await dbPlaylist.query(playlistTable,
        columns: [idColumn, ytIdColumn, nomeColumn, artistaColumn, urlColumn, thumbColumn],
        where: "$idColumn = ?",
        whereArgs: [id]
    );

    if(maps.length > 0){
      return Playlist.fromMap(maps.first);
    }else{
      return null;
    }

  }

  Future<int> deletePlaylist(int id) async{
    Database dbPlaylist = await db;
    return await dbPlaylist.delete(playlistTable,
        where: "$idColumn = ?",
        whereArgs: [id]
    );
  }

  Future<int> updatePlaylist(Playlist Playlist) async{
    Database dbPlaylist = await db;
    return await dbPlaylist.update(playlistTable,
        Playlist.toMap(),
        where: ("$idColumn = ?"),
        whereArgs: [Playlist.id]
    );
  }

  Future<List> getAllPlaylists() async{
    Database dbPlaylist = await db;
    List maps = await dbPlaylist.rawQuery("SELECT * FROM $playlistTable");
    List<Playlist> playlistList = List();

    for(Map m in maps){
      playlistList.add(Playlist.fromMap(m));
    }

    return playlistList;
  }

  Future<int> numPlaylists() async{
    Database dbPlaylist = await db;
    return Sqflite.firstIntValue(await dbPlaylist.rawQuery("SELECT COUNT(*) FROM $playlistTable"));
  }

  Future close() async{
    Database dbPlaylist = await db;
    await dbPlaylist.close();
  }

}

class Playlist{
  int id;
  String nome;
  String desc;
  List<Song> songList;

  Playlist();

  Playlist.fromMap(Map map){
    id = map[idColumn];
    nome = map[nomeColumn];
    desc = map[descColumn];
    songList = map[songColumn];
  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      nomeColumn: nome,
      descColumn: desc,
      songColumn: songList
    };

    if(id != null){
      map[idColumn] = id;
    }

    return map;
  }

}