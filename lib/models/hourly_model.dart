// Model for hourly weather data
class HourlyModel {
  final DateTime time;
  final double temperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;

  HourlyModel({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
  });

  // Convert JSON from API to HourlyModel object
  factory HourlyModel.fromJson(Map<String, dynamic> json, int index) {
    return HourlyModel(
      time: DateTime.parse(json['hourly']['time'][index]),
      temperature: json['hourly']['temperature_2m'][index].toDouble(),
      humidity: json['hourly']['relative_humidity_2m'][index],
      precipitation: (json['hourly']['precipitation'][index] ?? 0.0).toDouble(),
      weatherCode: json['hourly']['weather_code'][index],
    );
  }

  // Get hour in 12-hour format (e.g., "2 PM")
  String getFormattedHour() {
    final hour = time.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  // Get simple hour for chart (0-23)
  int getHour() {
    return time.hour;
  }

  // Get weather emoji based on code
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

  // Check if it's currently this hour
  bool isCurrentHour() {
    final now = DateTime.now();
    return time.year == now.year &&
           time.month == now.month &&
           time.day == now.day &&
           time.hour == now.hour;
  }
}