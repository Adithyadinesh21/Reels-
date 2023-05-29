import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'video_player_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'YouTube Shorts Clone',
            theme: themeModel.isDarkMode ? darkTheme : lightTheme,
            home: const VideoListScreen(),
          );
        },
      ),
    );
  }
}

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<dynamic> videoList = [];
  int currentPage = 1; // Starting page
  int perPage = 10; // Number of videos per page
  bool isLoading = false; // Indicates if a request is in progress

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchVideos();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Reached the bottom of the scroll view, load more videos
      if (!isLoading) {
        fetchVideos();
      }
    }
  }

  Future<void> fetchVideos() async {
    if (isLoading) {
      return; // Ignore if a request is already in progress
    }

    setState(() {
      isLoading = true; // Set isLoading to true while fetching videos
    });

    final url =
        'https://internship-service.onrender.com/videos?page=$currentPage&perPage=$perPage';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        var data2 = data['data'];

        if (data2.containsKey('posts')) {
          var posts = data2["posts"];

          setState(() {
            videoList.addAll(posts);
            currentPage++; // Increment the current page
            isLoading = false; // Set isLoading to false after fetching videos
          });
        }
      }
    } else {
      // Error handling if the API request fails
      setState(() {
        isLoading = false; // Set isLoading to false in case of error
      });
      print('Failed to fetch videos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        elevation: 0,
        title: Image.asset(
          'assets/youtube-logo-hd-8.png',
          height: 72,
          width: 90,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: Theme.of(context).iconTheme.color,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
            color: Theme.of(context).iconTheme.color,
          ),
          Consumer<ThemeModel>(
            builder: (context, themeModel, _) {
              return IconButton(
                onPressed: () {
                  themeModel.toggleDarkMode();
                },
                icon: Icon(
                  themeModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).iconTheme.color,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/60111.jpg'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: themeModel.isDarkMode ? Colors.grey[900] : Colors.grey[200],
          child: ListView.builder(
            controller: _scrollController,
            itemCount: videoList.length + 1,
            itemBuilder: (context, index) {
              if (index == videoList.length) {
                // Display a loading indicator at the end of the list while fetching more videos
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Container(); // Return an empty container when all videos are loaded
              }

              final video = videoList[index];
              var submission = video["submission"];
              final videoUrl = submission["mediaUrl"];
              final title = submission["title"];
              final thumbnail = submission["thumbnail"];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(videoUrl: videoUrl),
                    ),
                  );
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    // Swipe up to show the next video
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(videoUrl: videoUrl),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 9 / 14,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: themeModel.isDarkMode ? Colors.black : Colors.grey[900],
          primaryColor: themeModel.isDarkMode ? Colors.white : Colors.black,
          textTheme: Theme.of(context).textTheme.copyWith(
                caption: TextStyle(
                  color: themeModel.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            // Handle bottom navigation item tap
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'Shorts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.subscriptions),
              label: 'Subscriptions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeModel extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: const AppBarTheme(
    color: Colors.white,
  ),
  iconTheme: IconThemeData(
    color: Colors.grey[600],
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    color: Colors.black,
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
  ),
);
