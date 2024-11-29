// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import '/country.dart';
import '/api.dart';
import '/favorites.dart';
import 'country_details.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();
  List<Country> _favoriteCountries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCountries();
  }

  Future<void> _loadFavoriteCountries() async {
    try {
      final allCountries = await _apiService.getCountries();
      final favorites = await _favoritesService.getFavoriteCountries(allCountries);

      setState(() {
        _favoriteCountries = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: $e')),
      );
    }
  }

  void _removeFromFavorites(Country country) async {
    await _favoritesService.removeFromFavorites(country);
    _loadFavoriteCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Favorite Countries',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _favoriteCountries.isEmpty
                    ? Center(
                        child: Text(
                          'No favorite countries yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _favoriteCountries.length,
                        itemBuilder: (context, index) {
                          final country = _favoriteCountries[index];
                          return Dismissible(
                            key: Key(country.name),
                            background: Container(
                              color: Colors.red,
                              child: Icon(Icons.delete, color: Colors.white),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _removeFromFavorites(country);
                            },
                            child: Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: ListTile(
                                leading: Text(
                                  country.flag,
                                  style: TextStyle(fontSize: 30),
                                ),
                                title: Text(
                                  country.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Region: ${country.region}',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                trailing: Icon(Icons.favorite, color: Colors.red),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CountryDetailScreen(country: country),
                                    ),
                                  );
                                },
                              ),
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
