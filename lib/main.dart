import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'data.dart';
import 'models/story.model.dart';
import 'models/user.model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    /// 强制竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      /// ：stories 是一个数组 导入假数据
      home: StoryScreen(stories: stories),
    );
  }
}

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key, required this.stories}) : super(key: key);
  final List<Story> stories;
  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late VideoPlayerController _videoPlayerController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this);

    final Story firstStory = widget.stories.first;
    _loadStory(story: firstStory, animateToPage: false);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex += 1;
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            _currentIndex = 0;
            _loadStory(story: widget.stories[_currentIndex]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.stories[_currentIndex];
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(

            /// ?
            onTapDown: (details) => _onTapDown(details, story),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,

                  /// ?
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.stories.length,
                  itemBuilder: (context, index) {
                    /// ?
                    final Story story = widget.stories[index];
                    switch (story.media) {
                      case MediaType.image:
                        return CachedNetworkImage(
                          imageUrl: story.url,
                          fit: BoxFit.cover,
                        );
                      case MediaType.video:
                        if (_videoPlayerController.value.isInitialized) {
                          return FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoPlayerController.value.size.width,
                              height: _videoPlayerController.value.size.height,
                              child: VideoPlayer(_videoPlayerController),
                            ),
                          );
                        }
                    }

                    /// ?
                    return const SizedBox.shrink();
                  },
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      Row(
                        children: widget.stories
                            .asMap()
                            .map((i, e) {
                              return MapEntry(
                                i,
                                AnimatedBar(
                                  animationController: _animationController,
                                  position: i,
                                  currentIndex: _currentIndex,
                                ),
                              );
                            })
                            .values
                            .toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 1.5,
                          vertical: 10.0,
                        ),
                        child: UserInfo(
                          user: story.user,
                          key: null,
                        ),
                      )
                    ],
                  ),
                )
              ],
            )));
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex += 1;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          _currentIndex = 0;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else {
      if (story.media == MediaType.video) {
        if (_videoPlayerController.value.isPlaying) {
          _videoPlayerController.pause();
          _animationController.stop();
        } else {
          _videoPlayerController.play();
          _animationController.forward();
        }
      }
    }
  }

  void _loadStory({required Story story, bool animateToPage = true}) {
    _animationController.stop();
    _animationController.reset();
    switch (story.media) {
      case MediaType.image:
        _animationController.duration = story.duration;
        _animationController.forward();
        break;
      case MediaType.video:
        _videoPlayerController.dispose();
        _videoPlayerController = VideoPlayerController.network(story.url)
          ..initialize().then((_) {
            setState(() {});
            if (_videoPlayerController.value.isInitialized) {
              _animationController.duration =
                  _videoPlayerController.value.duration;
              _videoPlayerController.play();
              _animationController.forward();
            }
          });
        break;
    }
    if (animateToPage) {
      _pageController.animateToPage(_currentIndex,
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
  }
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar(
      {Key? key,
      required this.animationController,
      required this.position,
      required this.currentIndex})
      : super(key: key);
  final AnimationController animationController;
  final int position;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animationController.value,
                            Colors.white,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }
}

Container _buildContainer(double width, Color color) {
  return Container(
    height: 5.0,
    width: width,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(
        color: Colors.black26,
        width: 0.8,
      ),
      borderRadius: BorderRadius.circular(3.0),
    ),
  );
}

class UserInfo extends StatelessWidget {
  final User user;

  const UserInfo({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey[300],
          backgroundImage: CachedNetworkImageProvider(
            user.profileImageUrl,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}