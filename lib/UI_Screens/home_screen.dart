import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pip_demo/UI_Screens/search_result_page.dart';
import 'package:pip_demo/Widgets/shared_preference_widget.dart';

import 'login_screen.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> savedUser;

  const  HomePage({super.key, required this.savedUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final List<Map<String, dynamic>> _sampleHotels = [
    {
      'name': 'Grand Palace Hotel',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'country': 'India',
      'rating': 4.5,
      'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
    },
    {
      'name': 'Taj Residency',
      'city': 'Bangalore',
      'state': 'Karnataka',
      'country': 'India',
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400',
    },
    {
      'name': 'Ocean View Resort',
      'city': 'Goa',
      'state': 'Goa',
      'country': 'India',
      'rating': 4.3,
      'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400',
    },
    {
      'name': 'Mountain Peak Lodge',
      'city': 'Shimla',
      'state': 'Himachal Pradesh',
      'country': 'India',
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400',
    },
    {
      'name': 'Heritage Inn',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'country': 'India',
      'rating': 4.4,
      'image': 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=400',
    },

    {
      'name': 'The Taj Mahal Palace',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'country': 'India',
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
    },
    {
      'name': 'The Oberoi Udaivilas',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'country': 'India',
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
    },
    {
      'name': 'Leela Palace',
      'city': 'Bangalore',
      'state': 'Karnataka',
      'country': 'India',
      'rating': 4.0,
      'image': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',
    },
    {
      'name': 'ITC Grand Chola',
      'city': 'Chennai',
      'state': 'Kerala',
      'country': 'India',
      'rating': 4.5,
      'image': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',
    },
    {
      'name': 'Fairfield by Marriott',
      'city': 'Hyderabad',
      'state': 'Telangana',
      'country': 'India',
      'rating': 4.0,
      'image': 'https://images.unsplash.com/photo-1590490359683-658d3d23f972',
    },
    {
      'name': 'Trident Hotel',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'country': 'India',
      'rating': 3.9,
      'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
    },

  ];

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    final success = await SharedPreferenceWidget().deleteGoogleUserFromPrefs();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GoogleSignInPage()),
      );
    }
  }

  void _navigateToSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchResultsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signout') {
                _handleSignOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:widget.savedUser['photoUrl'] != null
                          ? NetworkImage(widget.savedUser['photoUrl']!)
                          : null,
                      child:widget.savedUser['photoUrl'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.savedUser['displayName'] ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.savedUser['email'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: widget.savedUser['photoUrl'] != null
                    ? NetworkImage(widget.savedUser['photoUrl']!)
                    : null,
                child: widget.savedUser['photoUrl'] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Your Perfect Stay',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToSearchPage,
                    icon: const Icon(Icons.search),
                    label: const Text(
                      'Search Hotels',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sampleHotels.length,
              itemBuilder: (context, index) {
                final hotel = _sampleHotels[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        hotel['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.hotel, size: 64),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${hotel['city']}, ${hotel['state']}, ${hotel['country']}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  hotel['rating'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}