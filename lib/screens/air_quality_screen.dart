import 'package:flutter/material.dart';
import '../services/weather_services.dart';

class AirQualityScreen extends StatefulWidget {
  final String cityName;

  const AirQualityScreen({super.key, required this.cityName});

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  Map<String, dynamic>? _airQualityData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAirQuality();
  }

  Future<void> _fetchAirQuality() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.getAirQuality(widget.cityName);
      setState(() {
        _airQualityData = data;
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
        title: Text('${widget.cityName} - Air Quality'),
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
                onPressed: _fetchAirQuality,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_airQualityData != null) {
      return SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildAQICard(),
                      const SizedBox(height: 16),
                      _buildPollutantsGrid(),
                      const SizedBox(height: 16),
                      _buildHealthAdviceCard(),
                      const SizedBox(height: 16),
                      _buildActivitiesCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _fetchAirQuality,
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

  Widget _buildAQICard() {
    final aqi = _airQualityData!['aqi'] as int;
    final category = _airQualityData!['category'] as String;
    final color = _airQualityData!['color'] as Color;
    final emoji = _airQualityData!['emoji'] as String;

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Air Quality Index',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '$aqi',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantsGrid() {
    final pollutants = _airQualityData!['pollutants'] as Map<String, int>;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        _buildPollutantCard(
            'PM2.5', pollutants['pm2_5']!, 'μg/m³', Icons.grain),
        _buildPollutantCard(
            'PM10', pollutants['pm10']!, 'μg/m³', Icons.blur_on),
        _buildPollutantCard('O₃', pollutants['ozone']!, 'μg/m³', Icons.cloud),
        _buildPollutantCard(
            'NO₂', pollutants['no2']!, 'μg/m³', Icons.local_gas_station),
      ],
    );
  }

  Widget _buildPollutantCard(
      String name, int value, String unit, IconData icon) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthAdviceCard() {
    final advice = _airQualityData!['healthAdvice'] as List<String>;

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Health Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...advice
                .map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesCard() {
    final activities = _airQualityData!['activities'] as Map<String, String>;

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.directions_run, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Activity Guidelines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityRow(
                Icons.sports, 'Outdoor Exercise', activities['outdoor']!),
            const SizedBox(height: 12),
            _buildActivityRow(
                Icons.door_back_door, 'Windows', activities['windows']!),
            const SizedBox(height: 12),
            _buildActivityRow(Icons.masks, 'Mask', activities['mask']!),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(
      IconData icon, String activity, String recommendation) {
    Color statusColor;
    Color bgColor;

    if (recommendation.contains('Recommended') ||
        recommendation.contains('safe')) {
      statusColor = Colors.white;
      bgColor = Colors.green;
    } else if (recommendation.contains('Consider') ||
        recommendation.contains('okay')) {
      statusColor = Colors.white;
      bgColor = Colors.deepOrange;
    } else {
      statusColor = Colors.white;
      bgColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
