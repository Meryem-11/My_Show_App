import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:show_app_flutter/config/api_config.dart';
import 'package:show_app_flutter/screens/add_show_page.dart';
import 'package:show_app_flutter/screens/profile_page.dart';
import 'package:show_app_flutter/screens/update_show_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> movies = [];
  List<dynamic> anime = [];
  List<dynamic> series = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShows();
  }

  Future<void> fetchShows() async {
    setState(() => isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/api/shows'));

      if (response.statusCode == 200) {
        List<dynamic> allShows = jsonDecode(response.body);

        setState(() {
          movies =
              allShows.where((show) => show['category'] == 'movie').toList();
          anime =
              allShows.where((show) => show['category'] == 'anime').toList();
          series =
              allShows.where((show) => show['category'] == 'serie').toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load shows');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading shows: $e")));
      }
    }
  }

  Future<void> deleteShow(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/shows/$id'),
      );

      if (response.statusCode == 200) {
        await fetchShows(); // Refresh list after deletion
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Show deleted successfully!")),
          );
        }
      } else {
        throw Exception('Failed to delete show');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting show: $e")));
      }
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Show"),
        content: const Text("Are you sure you want to delete this show?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteShow(id);
            },
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }

  void _navigateAndRefresh(Future<dynamic> Function() navigation) async {
    final result = await navigation();
    if (result == true) {
      await fetchShows();
    }
  }

  Widget _getBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return ShowList(
          shows: movies,
          onDelete: confirmDelete,
          onUpdate: fetchShows,
        );
      case 1:
        return ShowList(
          shows: anime,
          onDelete: confirmDelete,
          onUpdate: fetchShows,
        );
      case 2:
        return ShowList(
          shows: series,
          onDelete: confirmDelete,
          onUpdate: fetchShows,
        );
      default:
        return const Center(child: Text("Unknown Page"));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show App"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchShows),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (builder) => ProfilePage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Show"),
              onTap: () => _navigateAndRefresh(
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => AddShowPage()),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(onRefresh: fetchShows, child: _getBody()),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Anime"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ShowList extends StatelessWidget {
  final List<dynamic> shows;
  final Function(int) onDelete;
  final Function() onUpdate;

  const ShowList({
    super.key,
    required this.shows,
    required this.onDelete,
    required this.onUpdate,
  });

  void _showOptions(BuildContext context, Map<String, dynamic> show) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Show'),
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateShowPage(show: show),
                  ),
                );
                if (updated == true) {
                  onUpdate(); // Refresh the list
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Show updated successfully!"),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Show',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                onDelete(show['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (shows.isEmpty) {
      return const Center(child: Text("No Shows Available"));
    }

    return ListView.builder(
      itemCount: shows.length,
      itemBuilder: (context, index) {
        final show = shows[index];
        return Dismissible(
          key: Key(show['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => onDelete(show['id']),
          confirmDismiss: (direction) => onDelete(show['id']),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '${ApiConfig.baseUrl}${show['image']}',

                      width: 84,
                      height: 84,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          show['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          show['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context, show),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
