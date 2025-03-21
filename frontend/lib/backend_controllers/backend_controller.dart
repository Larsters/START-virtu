import 'dart:convert';
import 'dart:io';

import 'package:frontend/models/current_weather.dart';
import 'package:frontend/models/risk_stats.dart';
import 'package:frontend/models/soil_data.dart';
import 'package:http/http.dart' as http;

class BackendController {
  static final String baseUrl = 'http://10.0.0.2:8000';

  BackendController();

  Future<Map<String, dynamic>> _get(String endpoint,
      {Map<String, dynamic>? params}) async {
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

  static Future<SoilData> getSoilData(double latitude, double longitude) async {
    BackendController backend = BackendController();
    final result = await backend._get('getSoilData', params: {
      'latitude': latitude,
      'longitude': longitude
    });
    return SoilData.fromJson(result);
  }

  static Future<CurrentWeather> getWeatherData(double latitude, double longitude) async {
    BackendController backend = BackendController();
    final result = await backend._get('getCurrentWeather', params: {
      'latitude': latitude,
      'longitude': longitude
    });
    return CurrentWeather.fromJson(result);
  }

  static Future<RiskStats> getRiskStats(double latitude, double longitude, String crop) async {
    BackendController backend = BackendController();

    final result = await backend._get('getRiskStats', params: {
      'latitude': latitude,
      'longitude': longitude,
      'crop': crop
    });
    return RiskStats.fromJson(result);
  }

}

