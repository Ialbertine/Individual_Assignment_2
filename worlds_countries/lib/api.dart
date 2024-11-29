// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../country.dart';

class ApiService {
  static const String baseUrl = 'https://restcountries.com/v3.1';

  Future<List<Country>> getCountries() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/all'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Country>> getCountriesByRegion(String region) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/region/$region'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load countries by region');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}