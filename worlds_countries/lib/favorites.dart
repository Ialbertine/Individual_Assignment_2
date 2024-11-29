// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import '/country.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesKey = 'favorite_countries';

  // Add a country to favorites
  Future<void> addToFavorites(Country country) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing favorites
      List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

      // Convert country to JSON string for more robust storage
      String countryJson = json.encode({
        'name': country.name,
        'capital': country.capital,
      });

      // Check if country is not already in favorites
      if (!favorites.contains(countryJson)) {
        // Add country JSON to favorites
        favorites.add(countryJson);
        await prefs.setStringList(_favoritesKey, favorites);
      }
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Remove a country from favorites
  Future<void> removeFromFavorites(Country country) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing favorites
      List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

      // Convert country to JSON string
      String countryJson = json.encode({
        'name': country.name,
        'capital': country.capital,
      });

      // Remove country JSON from favorites
      favorites.remove(countryJson);
      await prefs.setStringList(_favoritesKey, favorites);
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  // Check if a country is a favorite
  Future<bool> isFavorite(Country country) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing favorites
      List<String>? favorites = prefs.getStringList(_favoritesKey);

      if (favorites == null) return false;

      // Convert country to JSON string
      String countryJson = json.encode({
        'name': country.name,
        'capital': country.capital,
      });

      return favorites.contains(countryJson);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Get all favorite countries
  Future<List<Country>> getFavoriteCountries(List<Country> allCountries) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing favorites
      List<String>? favorites = prefs.getStringList(_favoritesKey);

      if (favorites == null) return [];

      // Filter countries that are in favorites
      return allCountries.where((country) {
        String countryJson = json.encode({
          'name': country.name,
          'capital': country.capital,
        });
        return favorites.contains(countryJson);
      }).toList();
    } catch (e) {
      print('Error getting favorite countries: $e');
      return [];
    }
  }
}
