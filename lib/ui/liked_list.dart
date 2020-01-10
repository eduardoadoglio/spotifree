import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class likedVideos extends StatefulWidget {
  @override
  _likedVideosState createState() => _likedVideosState();
}

class _likedVideosState extends State<likedVideos> {

  Map<String, String> _likedVideos = Map();

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
    final directory = getApplicationDocumentsDirectory();
    String likedJson = json.encode(_likedVideos);
    File file = _getFile();

    return await file.writeAsString(likedJson);

  }



  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _getLikedVideos(),
        builder: (context, snapshot){
          return  ListTile(
            title: ,
          );
        },
      ),
    );
  }
}
