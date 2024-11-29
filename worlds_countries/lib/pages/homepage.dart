// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, sort_child_properties_last

import 'package:flutter/material.dart';
import '/api.dart';
import '/country.dart';
import 'country_details.dart';
import 'searchpage.dart';
import './country_card.dart';
import "./favoritepage.dart";


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Country> _countries = [];
  List<Country> _filteredCountries = [];
  bool _isLoading = true;
  String _selectedRegion = 'All';
  int _currentIndex = 0;

  // Pagination variables
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _apiService.getCountries();
      setState(() {
        _countries = countries;
        _filteredCountries = countries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading countries: $e')),
      );
    }
  }

  void _filterByRegion(String region) {
    setState(() {
      _selectedRegion = region;
      _currentPage = 0;
      if (region == 'All') {
        _filteredCountries = _countries;
      } else {
        _filteredCountries =
            _countries.where((country) => country.region == region).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Countries Explorer'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [

            LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        minWidth: constraints.maxWidth,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Enlarged image
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: isLandscape
                                    ? screenHeight * 0.3
                                    : screenHeight * 0.25),
                            child: Image.asset(
                              'assets/world.jpg',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Responsive dropdown
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.01),
                            child: DropdownButtonFormField<String>(
                              value: _selectedRegion,
                              decoration: InputDecoration(
                                labelText: 'Select Continent',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                'All',
                                'Africa',
                                'Americas',
                                'Asia',
                                'Europe',
                                'Oceania'
                              ].map((String region) {
                                return DropdownMenuItem<String>(
                                  value: region,
                                  child: Text(region),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _filterByRegion(value);
                                }
                              },
                            ),
                          ),
                          // Showing the countries list
                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: isLandscape
                                          ? screenHeight * 0.5
                                          : screenHeight * 0.6,
                                      child: GridView.builder(
                                        padding: EdgeInsets.all(8.0),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isLandscape ? 4 : 2,
                                          childAspectRatio:
                                              isLandscape ? 1.5 : 1.0,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount:
                                            _getPaginatedCountries().length,
                                        itemBuilder: (context, index) {
                                          final country =
                                              _getPaginatedCountries()[index];
                                          return CountryCard(
                                            country: country,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CountryDetailScreen(
                                                          country: country),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    // Minimized pagination controls
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02,
                                          vertical: screenHeight * 0.005),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            iconSize: 20,
                                            onPressed: _currentPage > 0
                                                ? () {
                                                    setState(() {
                                                      _currentPage--;
                                                    });
                                                  }
                                                : null,
                                            icon: Icon(Icons.arrow_back),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Page ${_currentPage + 1}',
                                            style: TextStyle(
                                                fontSize: isLandscape
                                                    ? screenWidth * 0.015
                                                    : screenWidth * 0.03),
                                          ),
                                          SizedBox(width: 10),
                                          IconButton(
                                            iconSize: 20,
                                            onPressed: (_currentPage + 1) *
                                                        _itemsPerPage <
                                                    _filteredCountries.length
                                                ? () {
                                                    setState(() {
                                                      _currentPage++;
                                                    });
                                                  }
                                                : null,
                                            icon: Icon(Icons.arrow_forward),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),

          SearchScreen(),
          FavoritesPage(),
        ],
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
      ],
    ),
  );
}

  List<Country> _getPaginatedCountries() {
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    return _filteredCountries.sublist(start,
        end > _filteredCountries.length ? _filteredCountries.length : end);
  }
}
