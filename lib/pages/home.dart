import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hyperlocal_news/services/data.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryMenu> categories = [];

  @override
  void initState() {
    super.initState();
    categories = getCategories().cast<CategoryMenu>();
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Oryno News',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.newspaper, size: 50),
      children: [
        const Text(
          'Oryno News is a hyperlocal news app providing the latest updates from your area.',
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
        setState(() {
          _locationMessage = "${place.country}";

          _isLoadingLocation = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Oryno ', style: TextStyle(fontWeight: FontWeight.w500)),
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
            icon: _isLoadingLocation
                ? const CircularProgressIndicator()
                : const Icon(Icons.location_pin),
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Categories feature coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bookmarks feature coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Change Location'),
              onTap: () {
                Navigator.pop(context);
                _getCurrentLocation();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings feature coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Exit'),
              onTap: () {
                Navigator.pop(context);
                _showExitDialog();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_locationMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Current Location: $_locationMessage',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else if (_locationMessage.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No location selected. Hit the location pin icon to get started.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
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
