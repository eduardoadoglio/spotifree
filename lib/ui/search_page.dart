import 'package:flutter/material.dart';
import 'package:fuck_spotify/helpers/playlistHelper.dart';
import 'package:fuck_spotify/helpers/songHelper.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_extractor/youtube_extractor.dart';

class searchPage extends StatefulWidget {
  @override
  searchPageState createState() => new searchPageState();
}

class searchPageState extends State<searchPage> {
  static int max = 5;
  static String key = "AIzaSyCTRdkP38K5gMspFV92QWedprDCa2ApaIY"; // coloca a tua key aqui nao vai rouba minha cota nao
  static String type = "video";
  YoutubeAPI ytApi = new YoutubeAPI(key, maxResults: max, type: type);
  List<YT_API> ytResult = [];

  String videoId;
  TextEditingController _queryController = TextEditingController();
  TextEditingController _playlistNameController = TextEditingController();
  TextEditingController _playlistDescController = TextEditingController();

  var extractor = YouTubeExtractor();
  var songUrl;

  SongHelper songHelper = SongHelper();
  PlaylistHelper playlistHelper = PlaylistHelper();

  List songs = [];
  List playlists = [];
  List selectedPlaylists = [];

  void _getAllSongs() {
    songHelper.getAllSongs().then((list) {
      songs = list;
    });
  }

  void _getAllPlaylists() {
    playlistHelper.getAllPlaylists().then((list){
      playlists = list;
    });
  }


call_API(query) async {
  print('UI callled');
  if (query != "" && query != null) {
    ytResult = await ytApi.search(query);
    print("cheguei");
    setState(() {
      print('UI Updated');
    });
  }
}


Future<String> _getUrl(id) async {
  songUrl = await extractor.getMediaStreamsAsync(id);
  if(songUrl.audio != null){
    return songUrl.audio.first.url;
  }

}

@override
void initState() {
  super.initState();
  _getAllSongs();
  _getAllPlaylists();
  print('hello');
}

@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: Text('Youtube API'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                        labelText: "Lansa a query",
                        labelStyle:
                            TextStyle(color: Colors.blue, fontSize: 20.0)),
                  ),
                ),
                RaisedButton(
                    child: Icon(Icons.search, color: Colors.white),
                    color: Colors.blue,
                    onPressed: () async {
                      await call_API(_queryController.text);
                    }),
              ],
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: ytResult.length,
                  itemBuilder: (_, int index) => ListItem(index)),
            ),
          ],
        ),
      ));
}

Widget ListItem(index) {
  return GestureDetector(
      onTap: () async => (ytResult[index] != null)
          ? await _getUrl(ytResult[index].id)// No futuro clicar no card resultará na musica tocando
          : print("error"),
      child: Card(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 7.0),
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Image.network(
                ytResult[index].thumbnail['default']['url'],
              ),
              Padding(padding: EdgeInsets.only(right: 20.0)),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    Text(
                      ytResult[index].title,
                      softWrap: true,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 1.5)),
                    Text(
                      ytResult[index].channelTitle,
                      softWrap: true,
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 3.0)),
                  ])),
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Pra qual playlist meu bom?"),
                            content: Container(
                              width: 300.0,
                              height: 200.0,
                              child: ListView.builder(
                                  itemCount: playlists.length,
                                  itemBuilder: (context, index){
                                    return playlistsCheck(index);
                                  }
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text("Criar nova playlist"),
                                  onPressed: () async{
                                    //String url = await _getUrl(ytResult[index].id);
                                    //print(url);
                                    Song selectedSong = Song();
                                    if(ytResult[index] != null){
                                      print(ytResult[index].id);
                                      selectedSong.nome = ytResult[index].title;
                                      selectedSong.ytId = ytResult[index].id;
                                      selectedSong.artista = ytResult[index].channelTitle;
                                      selectedSong.url = await _getUrl(ytResult[index].id);
                                      selectedSong.thumb = ytResult[index].thumbnail['default']['url'];
                                    }
                                    newPlaylistDialog(context, selectedSong);
                                    /*
                                      selectedSong = await songHelper.saveSong(selectedSong);
                                      newPlaylistDialog(context, selectedSong);
                                    }
                                    else{
                                      newPlaylistDialog(context, selectedSong);
                                    }
                                    */
                                  },
                              ),
                              FlatButton(
                                child: Text("Adicionar"),
                                onPressed: (){

                                },
                              ),
                              FlatButton(
                                  child: Text("Cancelar"),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  }
                              ),
                            ],
                          );
                        });
                  }),
            ],
          ),
        ),
      ));
  }

  Widget newPlaylistDialog(BuildContext context, Song song){
    Navigator.pop(context);
    final _playlistNameFocus = FocusNode();
    showDialog(
        context: context,
        builder: (context){
          return Container(
            child: AlertDialog(
              title: Text("Criar nova playlist"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    focusNode: _playlistNameFocus,
                    controller: _playlistNameController,
                    decoration: InputDecoration(
                        labelText: "Nome da Playlist",
                    )
                  ),
                  TextField(
                    controller: _playlistDescController,
                    decoration: InputDecoration(
                        labelText: "Descrição da Playlist",
                    )
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                    child: Text("Criar Playlist"),
                    onPressed: (){
                      /*
                      if(_playlistNameController.text.isNotEmpty &&
                          _playlistNameController.text != null){
                        /*List<Song> playlistSongs = [];
                        playlistSongs.add(song);
                        Playlist newPlaylist = Playlist();
                        newPlaylist.nome = _playlistNameController.text;
                        newPlaylist.desc = _playlistDescController.text;
                        newPlaylist.songList = playlistSongs;
                        playlistHelper.savePlaylist(newPlaylist);*/
                      }else{
                        FocusScope.of(context).requestFocus(_playlistNameFocus);
                      }*/

                    }
                ),
              ],
            ),
          );
        }
    );
  }

  Widget playlistsCheck(int index){
    return CheckboxListTile(
        value: playlists[index].nome,
        onChanged: (value){
          if(value){
            selectedPlaylists.add(playlists[index]);
          }else{
            selectedPlaylists.removeWhere((item) => item.id == playlists[index].id);
          }

        },
    );
  }
}
