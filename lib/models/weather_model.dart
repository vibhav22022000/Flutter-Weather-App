// This class represents our weather data
// It's like a blueprint that says "weather data looks like this"

class WeatherModel {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String cityName;
  final DateTime time;

  WeatherModel(
      {required this.temperature,
      required this.windSpeed,
      required this.weatherCode,
      required this.cityName,
      required this.time});

  // This converts JSON data from API into our WeatherModel object
  factory WeatherModel.fromJson(Map<String, dynamic> json, String city) {
    return WeatherModel(
      temperature: json['current']['temperature_2m'] ?? 0.0,
      windSpeed: json['current']['wind_speed_10m'] ?? 0.0,
      weatherCode: json['current']['weather_code'] ?? 0,
      cityName: city,
      time: DateTime.parse(json['current']['time']),
    );
  }

  // This converts weather code (0-99) into a description
  String getWeatherDescription() {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    if (weatherCode <= 82) return 'Rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    return 'Thunderstorm';
  }

  // Returns emoji based on weather
  String getWeatherEmoji() {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌦️';
    if (weatherCode <= 86) return '🌨️';
    return '⛈️';
  }
}
