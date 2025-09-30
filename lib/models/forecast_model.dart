// Model for daily forecast data
class ForecastModel {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  ForecastModel({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  // Convert JSON from API to ForecastModel object
  factory ForecastModel.fromJson(Map<String, dynamic> json, int index) {
    return ForecastModel(
      date: DateTime.parse(json['daily']['time'][index]),
      maxTemp: json['daily']['temperature_2m_max'][index].toDouble(),
      minTemp: json['daily']['temperature_2m_min'][index].toDouble(),
      weatherCode: json['daily']['weather_code'][index],
    );
  }

  // Get weather description based on code
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

  // Get weather emoji
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

  // Get day of week (Mon, Tue, etc.)
  String getDayOfWeek() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}