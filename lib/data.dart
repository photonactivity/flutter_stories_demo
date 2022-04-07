import 'package:flutter_stories_demo/models/user.model.dart';

import 'models/story.model.dart';

///  模拟服务器数据

final User user1 = User(
  'user1',
  'https://images.unsplash.com/photo-1648737154448-ccf0cafae1c2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
);

final User user2 = User(
  'user2',
  'https://images.unsplash.com/photo-1605910959675-2e28d06cc321?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
);

final List<Story> stories = [
  Story(
    'https://images.unsplash.com/photo-1605910460735-8b9e36472ede?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1102&q=80',
    MediaType.image,
    const Duration(seconds: 10),
    user1,
  ),
  Story(
    'https://images.unsplash.com/photo-1648885645110-83da8679b7ff?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
    MediaType.image,
    const Duration(seconds: 10),
    user2,
  )
];
