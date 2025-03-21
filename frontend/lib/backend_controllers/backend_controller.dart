import 'dart:convert';
import 'package:frontend/models/soil_data.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class BackendController {
  static final String baseUrl = 'https://localhost:8000';

  BackendController();

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      var uri = Uri.parse('$baseUrl/$endpoint');
      
      // Add query parameters if they exist
      if (params != null && params.isNotEmpty) {
        // Convert all parameter values to strings
        final stringParams = params.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        uri = uri.replace(queryParameters: stringParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers here if needed
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          return decodedBody;
        } else {
          throw FormatException(
            'Response was not in the expected format. Got ${decodedBody.runtimeType}',
          );
        }
      } else {
        throw HttpException(
          'Failed to load data: ${response.statusCode}',
          uri: uri,
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> getAny(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException(
          'Failed to load data: ${response.statusCode}',
          uri: Uri.parse('$baseUrl/$endpoint'),
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // You might want to add methods for specific endpoints
  Future<Map<String, dynamic>> getFarms({
    String? searchTerm,
    int? limit,
    int? page,
  }) async {
    final params = <String, dynamic>{
      if (searchTerm != null) 'search': searchTerm,
      if (limit != null) 'limit': limit,
      if (page != null) 'page': page,
    };
    return get('farms', params: params);
  }

  Future<Map<String, dynamic>> getFarmById(String id) async {
    return get('farms/$id');
  }



  static Future<SoilData> getSoilData(double latitude, double longitude) async {
    BackendController backend = BackendController();
    final result = await backend.get('getSoilData', params:{
      'latitude': latitude,
      'longitude': longitude
    });
    return SoilData.fromJson(result);
  }

  static Future<Map<String, dynamic>?> getWeatherData(double latitude, double longitude) async {
    BackendController backend = BackendController();
    final result = await backend.get('getCurrentWeather', params:{
      'latitude': latitude,
      'longitude': longitude
    });
    return result;
  }

}

