import 'package:flutter/material.dart';
import 'package:fuck_spotify/ui/liked_list.dart';
import 'package:fuck_spotify/ui/search_page.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_extractor/youtube_extractor.dart';

void main() {
  runApp(MaterialApp(
    home: likedVideos(),
    debugShowCheckedModeBanner: false,
  ));
}

