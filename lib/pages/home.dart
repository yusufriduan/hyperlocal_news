import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hyperlocal_news/services/data.dart';
import '../models/article_model.dart';
import '../services/news_service.dart';
import 'article_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final NewsApiService _newsApiService = NewsApiService();
  String _currentCountryCode = 'us';
  late Future<List<Article>> _newsFuture;
  List<CategoryMenu> categories = [];

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsApiService.fetchTopHeadlines('us');
    categories = getCategories().cast<CategoryMenu>();
  }

  String _locationMessage = "";
  bool _isLoadingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationMessage = "Getting location...";
      _isLoadingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = "Location services are disabled.";
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = "Location permissions are denied.";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = "Location permissions are permanently denied.";
          _isLoadingLocation = false;
        });
        return;
      }

      Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 15),
            ),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception("Location request timed out");
            },
          );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String countryCode = place.isoCountryCode ?? 'US';
        setState(() {
          _locationMessage = "${place.country}";
          _isLoadingLocation = false;
          _currentCountryCode = countryCode;
          debugPrint(_currentCountryCode);
          _fetchNewsForCountry(countryCode);
        });
      } else {
        setState(() {
          _locationMessage = "No address available for the location.";
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationMessage = "Error getting location: $e";
      });
    }
  }

  void _fetchNewsForCountry(String country) {
    setState(() {
      _newsFuture = _newsApiService.fetchTopHeadlines(country.toLowerCase());
    });
  }

  void _fetchNewsForCategory(String category) {
    setState(() {
      _newsFuture = _newsApiService.fetchNewsByCategory(_currentCountryCode.toLowerCase(), category);
    });
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Oryno News',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.newspaper, size: 50),
      children: [
        const Text(
          'Oryno News is a hyperlocal news app providing the latest updates from your country.',
        ),
        const SizedBox(height: 10),
        const Text('Developed by Yusuf Riduan.'),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: const [
            Text('Oryno', style: TextStyle(fontWeight: FontWeight.w500)),
            Text(
              'News',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight:
                    FontWeight.bold, // Optional: add color to differentiate
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification feature coming soon!'),
              ),
            ),
            icon: const Icon(Icons.notifications),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5.0), // Add some spacing
            child: TextButton.icon(
              style: TextButton.styleFrom(
                // Ensure the button's text and icon are visible on the AppBar
                foregroundColor: Theme.of(context).appBarTheme.actionsIconTheme?.color,
                // Disable the ripple effect when loading
                splashFactory: _isLoadingLocation ? NoSplash.splashFactory : null,
              ),
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: _isLoadingLocation
              // Show a smaller progress indicator that fits well
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
                  : const Icon(Icons.location_on, size: 20),
              label: Text(
                // Display location message if not loading and message is available
                // Otherwise, show nothing.
                !_isLoadingLocation && _locationMessage.isNotEmpty
                    ? _locationMessage
                    : '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Top section with main menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      _fetchNewsForCountry(_currentCountryCode);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Followed News'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Followed News section coming soon!'),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.money),
                    title: const Text('Business'),
                    onTap: () {
                      Navigator.pop(context);
                      _fetchNewsForCategory('business');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.movie),
                    title: const Text('Entertainment'),
                    onTap: () {
                      Navigator.pop(context);
                      _fetchNewsForCategory('entertainment');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.health_and_safety),
                    title: const Text('Health'),
                    onTap: () {
                      Navigator.pop(context);
                      _fetchNewsForCategory('health');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.science),
                    title: const Text('Science'),
                    onTap: () {
                      Navigator.pop(context);
                      _fetchNewsForCategory('science');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sports_soccer),
                    title: const Text('Sports'),
                    onTap: () {
                      Navigator.pop(context);
                      _fetchNewsForCategory('sports');
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: bottomPadding > 0 ? bottomPadding : 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog();
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text('Exit'),
                      titleTextStyle: const TextStyle(color: Colors.red),
                      onTap: () {
                        Navigator.pop(context);
                        _showExitDialog();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder<List<Article>>(
                  future: _newsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No articles found.'),
                      );
                    } else {
                      List<Article> articles = snapshot.data!;
                      return ListView.builder(
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          final article = articles[index];
                          return ListTile(
                            leading: article.image != null
                                ? Image.network(
                              article.image!,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                            )
                                : SizedBox(
                              width: 100,
                              child: const Icon(Icons.image_not_supported),
                            ),
                            title: Text(article.title),
                            subtitle: Text(
                              article.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleView(
                                    articleUrl: article.url,
                                    publisherName: article.source.name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  }
              )
          )
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refresh feature coming soon!')),
          );
        },
        label: const Text('Refresh'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}

class CategoryMenu extends StatelessWidget {
  final String categoryName;

  const CategoryMenu({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
