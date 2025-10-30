import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final String _baseUrl = 'https://api.mytravaly.com/public/v1/';
  final String _authToken = '71523fdd8d26f585315b4233e39d9263';

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allHotels = [];
  List<dynamic> _filteredHotels = [];
  bool _isLoadingInitial = true;
  bool _isSearching = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAllHotels();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isSearching &&
        _hasMoreData &&
        _searchController.text.isEmpty) {
      _loadMoreHotels();
    }
  }

  // Fetch all hotels initially
  Future<void> _fetchAllHotels({bool loadMore = false}) async {
    if (_isSearching && !loadMore) return;

    setState(() {
      if (loadMore) {
        _isSearching = true;
      } else {
        _isLoadingInitial = true;
        _hasError = false;
        _errorMessage = '';
      }
    });

    try {
      // Fetch hotels list (adjust endpoint as per your API)
      final response = await http.get(
        Uri.parse('${_baseUrl}hotels?page=$_currentPage&limit=$_itemsPerPage'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          if (loadMore) {
            _allHotels.addAll(data['data'] ?? []);
          } else {
            _allHotels = data['data'] ?? [];
          }
          _filteredHotels = List.from(_allHotels);
          _hasMoreData = (data['data'] ?? []).length >= _itemsPerPage;
          _isLoadingInitial = false;
          _isSearching = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Failed to load hotels. Status: ${response.statusCode}';
          _isLoadingInitial = false;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error: $e';
        _isLoadingInitial = false;
        _isSearching = false;
      });
    }
  }

  Future<void> _loadMoreHotels() async {
    _currentPage++;
    await _fetchAllHotels(loadMore: true);
  }

  // Search within fetched hotels
  void _searchHotels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHotels = List.from(_allHotels);
      } else {
        _filteredHotels = _allHotels.where((hotel) {
          final name = hotel['name']?.toString().toLowerCase() ?? '';
          final city = hotel['city']?.toString().toLowerCase() ?? '';
          final state = hotel['state']?.toString().toLowerCase() ?? '';
          final country = hotel['country']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
              city.contains(searchLower) ||
              state.contains(searchLower) ||
              country.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    _hasMoreData = true;
    _searchController.clear();
    await _fetchAllHotels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hotels'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by hotel, city, state, or country',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchHotels('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchHotels,
            ),
          ),

          // Results count
          if (!_isLoadingInitial && !_hasError)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredHotels.length} hotel(s) found',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Hotels List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading hotels...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredHotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No hotels available'
                  : 'No hotels found',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Please try again later'
                  : 'Try searching with different keywords',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredHotels.length + (_isSearching ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredHotels.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final hotel = _filteredHotels[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(hotel['name'] ?? 'Hotel'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hotel ID: ${hotel['id'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      if (hotel['description'] != null)
                        Text(hotel['description']),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hotel['image_url'] != null)
                  Image.network(
                    hotel['image_url'],
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
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.hotel, size: 64, color: Colors.grey),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel['name'] ?? 'Hotel Name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (hotel['city'] != null || hotel['state'] != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                [
                                  hotel['city'],
                                  hotel['state'],
                                  hotel['country']
                                ].where((e) => e != null).join(', '),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (hotel['rating'] != null) ...[
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
                      if (hotel['price'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '₹${hotel['price']} per night',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
