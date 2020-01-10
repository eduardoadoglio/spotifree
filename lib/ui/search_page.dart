import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_extractor/youtube_extractor.dart';


class searchPage extends StatefulWidget {
  @override
  searchPageState createState() => new searchPageState();
}


class searchPageState extends State<searchPage> {
  static int max = 10;
  static String key; // coloca a tua key aqui nao vai rouba minha cota nao

  YoutubeAPI ytApi = new YoutubeAPI(key, maxResults: max);
  List<YT_API> ytResult = [];

  String videoId;
  TextEditingController _queryController = TextEditingController();

  var extractor = YouTubeExtractor();
  var songUrl;
  Map<String, List<String>> _likedVideos = Map();

  call_API(query) async {
    print('UI callled');
    if(query != "" && query != null){
      ytResult = await ytApi.search(query);
      print("cheguei");
      setState(() {
        print('UI Updated');
      });
    }
  }

  _getId(YT_API result) async{
    videoId = result.id;
    print(videoId);
    await _playSong(videoId);
  }

  Future<String> _playSong(id) async{
    songUrl = await extractor.getMediaStreamsAsync(id);
    return songUrl.audio.first.url;
  }

  Future<Map> _getLikedVideos() async{
    File file = _getFile();
    String likedJson = await file.readAsString();
    return json.decode(likedJson);
  }


  File _getFile(){
    final directory = getApplicationDocumentsDirectory();
    return File("${directory}/data.json");
  }

  Future _saveFile() async{
    String likedJson = json.encode(_likedVideos);
    File file = _getFile();

    return await file.writeAsString(likedJson);

  }
  @override
  void initState() {
    super.initState();
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
                          labelStyle: TextStyle(color: Colors.blue, fontSize: 20.0)
                      ),
                    ),
                  ),
                  RaisedButton(
                      child: Icon(Icons.search, color: Colors.white),
                      color: Colors.blue,
                      onPressed: () async{
                        await call_API(_queryController.text);
                      }
                  ),
                ],
              ),

              Expanded(
                child: ListView.builder(
                    itemCount: ytResult.length,
                    itemBuilder: (_, int index) => ListItem(index)
                ),
              ),
            ],
          ),
        )
    );
  }
  Widget ListItem(index){
    return GestureDetector(
        onTap: () async => (ytResult[index] != null) ? await _getId(ytResult[index]) : print("error"),
        child: Card(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 7.0),
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Image.network(ytResult[index].thumbnail['default']['url'],),
                Padding(padding: EdgeInsets.only(right: 20.0)),
                Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        ytResult[index].title,
                        softWrap: true,
                        style: TextStyle(fontSize:18.0),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 1.5)),
                      Text(
                        ytResult[index].channelTitle,
                        softWrap: true,
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 3.0)),
                      Text(
                        ytResult[index].url,
                        softWrap: true,
                      ),
                    ]
                )),
                FlatButton(
                  onPressed: () async{
                    String id = ytResult[index].id;
                    String name = ytResult[index].title;
                    String url = await _playSong(id);
                    List<String> videoDescription = [name, url];
                    setState(() {
                      if(_likedVideos.containsKey(id)){
                        _likedVideos.remove(id);
                      }else{
                        _likedVideos.addAll({id: videoDescription});
                      }
                      _saveFile();
                    });
                  },
                  child: Icon(_likedVideos.containsKey(ytResult[index].id) ? Icons.star : Icons.star_border, color: Colors.yellowAccent),
                )

              ],
            ),
          ),
        )
    );
  }
}