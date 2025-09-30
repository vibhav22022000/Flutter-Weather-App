import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/hourly_model.dart';

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  static const Map<String, Map<String, double>> cities = {
    'London': {'lat': 51.5074, 'lon': -0.1278},
    'New York': {'lat': 40.7128, 'lon': -74.0060},
    'Tokyo': {'lat': 35.6762, 'lon': 139.6503},
    'Paris': {'lat': 48.8566, 'lon': 2.3522},
    'Chicago': {'lat': 41.8781, 'lon': -87.6298},
    'Mumbai': {'lat': 19.0760, 'lon': 72.8777},
    'Sydney': {'lat': -33.8688, 'lon': 151.2093},
  };

  Future<WeatherModel> getWeather(String cityName) async {
    try {
      final coords = cities[cityName];
      if (coords == null) {
        throw Exception('City not found');
      }

      final url = Uri.parse(
        '$baseUrl?latitude=${coords['lat']}&longitude=${coords['lon']}'
        '&current=temperature_2m,wind_speed_10m,weather_code'
        '&temperature_unit=celsius'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return WeatherModel.fromJson(jsonData, cityName);
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<List<ForecastModel>> getForecast(String cityName) async {
    try {
      final coords = cities[cityName];
      if (coords == null) {
        throw Exception('City not found');
      }

      final url = Uri.parse(
        '$baseUrl?latitude=${coords['lat']}&longitude=${coords['lon']}'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code'
        '&temperature_unit=celsius'
        '&timezone=auto'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ForecastModel> forecasts = [];
        for (int i = 0; i < 7; i++) {
          forecasts.add(ForecastModel.fromJson(jsonData, i));
        }
        return forecasts;
      } else {
        throw Exception('Failed to load forecast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  Future<List<HourlyModel>> getHourlyForecast(String cityName) async {
    try {
      final coords = cities[cityName];
      if (coords == null) {
        throw Exception('City not found');
      }

      final url = Uri.parse(
        '$baseUrl?latitude=${coords['lat']}&longitude=${coords['lon']}'
        '&hourly=temperature_2m,relative_humidity_2m,precipitation,weather_code'
        '&temperature_unit=celsius'
        '&timezone=auto'
        '&forecast_days=2'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<HourlyModel> hourlyData = [];
        final now = DateTime.now();
        final startIndex = now.hour;
        
        for (int i = startIndex; i < startIndex + 24; i++) {
          hourlyData.add(HourlyModel.fromJson(jsonData, i));
        }
        return hourlyData;
      } else {
        throw Exception('Failed to load hourly forecast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching hourly forecast: $e');
    }
  }

  // NEW: Get detailed weather information
  Future<Map<String, dynamic>> getDetailedWeather(String cityName) async {
    try {
      final coords = cities[cityName];
      if (coords == null) {
        throw Exception('City not found');
      }

      final url = Uri.parse(
        '$baseUrl?latitude=${coords['lat']}&longitude=${coords['lon']}'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
        'weather_code,cloud_cover,pressure_msl,visibility'
        '&daily=sunrise,sunset'
        '&temperature_unit=celsius'
        '&timezone=auto'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        final sunriseStr = jsonData['daily']['sunrise'][0];
        final sunsetStr = jsonData['daily']['sunset'][0];
        
        return {
          'temperature': jsonData['current']['temperature_2m'].toDouble(),
          'feelsLike': jsonData['current']['apparent_temperature'].toDouble(),
          'humidity': jsonData['current']['relative_humidity_2m'],
          'pressure': jsonData['current']['pressure_msl'].toDouble(),
          'visibility': jsonData['current']['visibility'].toDouble(),
          'clouds': jsonData['current']['cloud_cover'],
          'weatherCode': jsonData['current']['weather_code'],
          'description': _getWeatherDescription(jsonData['current']['weather_code']),
          'emoji': _getWeatherEmoji(jsonData['current']['weather_code']),
          'sunrise': DateTime.parse(sunriseStr),
          'sunset': DateTime.parse(sunsetStr),
        };
      } else {
        throw Exception('Failed to load detailed weather');
      }
    } catch (e) {
      throw Exception('Error fetching detailed weather: $e');
    }
  }

  List<String> getCities() {
    return cities.keys.toList();
  }

  // Helper methods
  String _getWeatherDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    return 'Thunderstorm';
  }

  String _getWeatherEmoji(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    return '⛈️';
  }

  // NEW: Get weather trends for past 7 days
  Future<List<Map<String, dynamic>>> getWeatherTrends(String cityName) async {
    try {
      final coords = cities[cityName];
      if (coords == null) {
        throw Exception('City not found');
      }

      final url = Uri.parse(
        '$baseUrl?latitude=${coords['lat']}&longitude=${coords['lon']}'
        '&daily=temperature_2m_max,temperature_2m_min'
        '&temperature_unit=celsius'
        '&timezone=auto'
        '&past_days=7'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<Map<String, dynamic>> trends = [];
        
        final List<String> dayLabels = ['7d ago', '6d ago', '5d ago', '4d ago', '3d ago', '2d ago', 'Yesterday', 'Today'];
        
        for (int i = 0; i < 8; i++) {
          final maxTemp = jsonData['daily']['temperature_2m_max'][i].toDouble();
          final minTemp = jsonData['daily']['temperature_2m_min'][i].toDouble();
          final avgTemp = (maxTemp + minTemp) / 2;
          
          trends.add({
            'dayLabel': dayLabels[i],
            'maxTemp': maxTemp,
            'minTemp': minTemp,
            'avgTemp': avgTemp,
          });
        }
        
        return trends;
      } else {
        throw Exception('Failed to load trends');
      }
    } catch (e) {
      throw Exception('Error fetching trends: $e');
    }
  }

  // NEW: Get air quality data
  Future<Map<String, dynamic>> getAirQuality(String cityName) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulated AQI based on city
    final Map<String, int> baseAQI = {
      'London': 45,
      'New York': 55,
      'Tokyo': 35,
      'Paris': 50,
      'Chicago': 60,
      'Mumbai': 120,
      'Sydney': 25,
    };
    
    final aqi = baseAQI[cityName] ?? 50;
    
    String category;
    Color color;
    String emoji;
    List<String> healthAdvice;
    Map<String, String> activities;
    
    if (aqi <= 50) {
      category = 'Good';
      color = Colors.green;
      emoji = '😊';
      healthAdvice = [
        'Air quality is satisfactory',
        'Perfect for outdoor activities',
        'No health concerns for anyone',
      ];
      activities = {
        'outdoor': 'Recommended - air is safe',
        'windows': 'Open windows freely',
        'mask': 'Not necessary',
      };
    } else if (aqi <= 100) {
      category = 'Moderate';
      color = Colors.yellow.shade700;
      emoji = '😐';
      healthAdvice = [
        'Air quality is acceptable',
        'Unusually sensitive people should limit prolonged outdoor exposure',
        'General public not affected',
      ];
      activities = {
        'outdoor': 'Okay for most people',
        'windows': 'Ventilation is fine',
        'mask': 'Consider if sensitive',
      };
    } else if (aqi <= 150) {
      category = 'Unhealthy for Sensitive';
      color = Colors.orange;
      emoji = '😷';
      healthAdvice = [
        'Sensitive groups may experience health effects',
        'General public less likely to be affected',
        'Reduce prolonged or heavy outdoor exertion',
      ];
      activities = {
        'outdoor': 'Reduce if sensitive',
        'windows': 'Keep closed if sensitive',
        'mask': 'Recommended for sensitive groups',
      };
    } else if (aqi <= 200) {
      category = 'Unhealthy';
      color = Colors.red;
      emoji = '😨';
      healthAdvice = [
        'Everyone may begin to experience health effects',
        'Sensitive groups may experience serious effects',
        'Avoid prolonged outdoor activities',
      ];
      activities = {
        'outdoor': 'Avoid strenuous activities',
        'windows': 'Keep windows closed',
        'mask': 'Recommended for everyone',
      };
    } else {
      category = 'Very Unhealthy';
      color = Colors.purple;
      emoji = '😱';
      healthAdvice = [
        'Health alert - everyone may experience serious effects',
        'Stay indoors as much as possible',
        'Avoid all outdoor activities',
      ];
      activities = {
        'outdoor': 'Stay indoors',
        'windows': 'Keep all windows closed',
        'mask': 'Required when outside',
      };
    }
    
    return {
      'aqi': aqi,
      'category': category,
      'color': color,
      'emoji': emoji,
      'healthAdvice': healthAdvice,
      'activities': activities,
      'pollutants': {
        'pm2_5': (aqi * 0.5).round(),
        'pm10': (aqi * 0.8).round(),
        'ozone': (aqi * 0.6).round(),
        'no2': (aqi * 0.4).round(),
      },
    };
  }
}