import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/flood_zone.dart';

class ApiService {
  static const String baseUrl = 'http://confidential:5000/api';


  // Get all flood zones
  static Future<List<FloodZone>> getFloodZones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/flood-zones'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((zone) => FloodZone.fromJson(zone)).toList();
      } else {
        throw 'Failed to load flood zones';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Get nearby flood zones
  static Future<List<FloodZone>> getNearbyFloodZones(
    double latitude,
    double longitude, [
    double radius = 5,
  ]) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/flood-zones/nearby?latitude=$latitude&longitude=$longitude&radius=$radius',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((zone) => FloodZone.fromJson(zone)).toList();
      } else {
        throw 'Failed to load nearby flood zones';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Get flood risk prediction
  static Future<Map<String, dynamic>> getPrediction(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/flood-zones/predict-risk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to get prediction';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Get all shelters
  static Future<List<Shelter>> getShelters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shelters'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((shelter) => Shelter.fromJson(shelter)).toList();
      } else {
        throw 'Failed to load shelters';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Get nearby shelters
  static Future<List<Shelter>> getNearByShelters(
    double latitude,
    double longitude, [
    double radius = 10,
  ]) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/shelters/nearby?latitude=$latitude&longitude=$longitude&radius=$radius',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((shelter) => Shelter.fromJson(shelter)).toList();
      } else {
        throw 'Failed to load nearby shelters';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body)['error'] ?? 'Registration failed';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body)['error'] ?? 'Login failed';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Update user location
  static Future<void> updateUserLocation(
    int userId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/update-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw 'Failed to update location';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Get current weather
  static Future<Map<String, dynamic>> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/weather/current?latitude=$latitude&longitude=$longitude',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to get weather';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }
}