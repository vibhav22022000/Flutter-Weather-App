import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_services.dart';

class DetailsScreen extends StatefulWidget {
  final String cityName;

  const DetailsScreen({super.key, required this.cityName});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  Map<String, dynamic>? _detailedData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetailedWeather();
  }

  Future<void> _fetchDetailedWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.getDetailedWeather(widget.cityName);
      setState(() {
        _detailedData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} - Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlue.shade100],
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetailedWeather,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_detailedData != null) {
      return SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 16),
                      _buildSunCard(),
                      const SizedBox(height: 16),
                      _buildDetailsGrid(),
                      const SizedBox(height: 16),
                      _buildComfortCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _fetchDetailedWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Text('No data available', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildHeaderCard() {
    final temp = _detailedData!['temperature'];
    final feelsLike = _detailedData!['feelsLike'];
    final description = _detailedData!['description'];
    final emoji = _detailedData!['emoji'];

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 12),
            Text(
              '${temp.round()}°C',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Feels like ${feelsLike.round()}°C',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunCard() {
    final sunrise = _detailedData!['sunrise'] as DateTime;
    final sunset = _detailedData!['sunset'] as DateTime;
    final now = DateTime.now();
    
    final sunriseTime = DateFormat('HH:mm').format(sunrise);
    final sunsetTime = DateFormat('HH:mm').format(sunset);
    
    final dayLength = sunset.difference(sunrise);
    final hours = dayLength.inHours;
    final minutes = dayLength.inMinutes % 60;

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  now.isAfter(sunrise) && now.isBefore(sunset)
                      ? Icons.wb_sunny
                      : Icons.nightlight,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  now.isAfter(sunrise) && now.isBefore(sunset)
                      ? 'Daytime'
                      : 'Nighttime',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSunItem(Icons.wb_sunny, 'Sunrise', sunriseTime, Colors.orange),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildSunItem(Icons.wb_twilight, 'Sunset', sunsetTime, Colors.deepOrange),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Day Length: ${hours}h ${minutes}m',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunItem(IconData icon, String label, String time, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildDetailCard(
          Icons.water_drop,
          'Humidity',
          '${_detailedData!['humidity']}%',
          Colors.blue,
        ),
        _buildDetailCard(
          Icons.speed,
          'Pressure',
          '${_detailedData!['pressure']} hPa',
          Colors.purple,
        ),
        _buildDetailCard(
          Icons.visibility,
          'Visibility',
          '${(_detailedData!['visibility'] / 1000).toStringAsFixed(1)} km',
          Colors.cyan,
        ),
        _buildDetailCard(
          Icons.cloud,
          'Clouds',
          '${_detailedData!['clouds']}%',
          Colors.blueGrey,
        ),
      ],
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value, Color color) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComfortCard() {
    final temp = _detailedData!['temperature'];
    final humidity = _detailedData!['humidity'];
    
    String comfortLevel;
    String comfortEmoji;
    Color comfortColor;
    Color bgColor;
    
    if (temp < 0) {
      comfortLevel = 'Freezing Cold';
      comfortEmoji = '🥶';
      comfortColor = Colors.white;
      bgColor = Colors.blue;
    } else if (temp < 10) {
      comfortLevel = 'Very Cold';
      comfortEmoji = '❄️';
      comfortColor = Colors.white;
      bgColor = Colors.lightBlue;
    } else if (temp < 20) {
      comfortLevel = 'Cool';
      comfortEmoji = '😊';
      comfortColor = Colors.white;
      bgColor = Colors.cyan;
    } else if (temp < 25) {
      comfortLevel = 'Comfortable';
      comfortEmoji = '😎';
      comfortColor = Colors.white;
      bgColor = Colors.green;
    } else if (temp < 30) {
      comfortLevel = 'Warm';
      comfortEmoji = '🌞';
      comfortColor = Colors.white;
      bgColor = Colors.orange;
    } else {
      comfortLevel = 'Very Hot';
      comfortEmoji = '🔥';
      comfortColor = Colors.white;
      bgColor = Colors.red;
    }

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Comfort Index',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(comfortEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                comfortLevel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: comfortColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              humidity > 70
                  ? 'High humidity may make it feel warmer'
                  : humidity < 30
                      ? 'Low humidity - air feels dry'
                      : 'Humidity is at comfortable levels',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}