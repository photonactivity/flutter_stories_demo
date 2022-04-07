import 'package:flutter_stories_demo/models/user.model.dart';

enum MediaType {
  image,
  video,
}

class Story {
  final String url;
  final MediaType media;
  final Duration duration;
  final User user;

  Story(
    this.url,
    this.media,
    this.duration,
    this.user,
  );
}