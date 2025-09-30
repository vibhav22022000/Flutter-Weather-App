import 'package:flutter/material.dart';
import '../models/hourly_model.dart';
import '../services/weather_services.dart';

class HourlyScreen extends StatefulWidget {
  final String cityName;

  const HourlyScreen({super.key, required this.cityName});

  @override
  State<HourlyScreen> createState() => _HourlyScreenState();
}

class _HourlyScreenState extends State<HourlyScreen> {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  List<HourlyModel>? _hourlyData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHourlyData();
  }

  Future<void> _fetchHourlyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.getHourlyForecast(widget.cityName);
      
      setState(() {
        _hourlyData = data;
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
        title: Text('${widget.cityName} - 24 Hour Forecast'),
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
                onPressed: _fetchHourlyData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_hourlyData != null && _hourlyData!.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.white.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Next 24 Hours',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Temperature Chart
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Card(
                      color: Colors.white.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Temperature Trend (°C)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 140,
                              child: _buildSimpleTemperatureChart(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Temperature Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      color: Colors.white.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _buildTemperatureSummary(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Hourly details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _hourlyData!.map((hour) => _buildHourlyCard(hour)).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Refresh button - Clean design without extra container
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _fetchHourlyData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSimpleTemperatureChart() {
    if (_hourlyData == null || _hourlyData!.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final temps = _hourlyData!.map((e) => e.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final tempRange = maxTemp - minTemp;

    return ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(_hourlyData!.length, (index) {
            final hour = _hourlyData![index];
            final normalizedHeight = tempRange > 0 
                ? ((hour.temperature - minTemp) / tempRange) * 90 + 12
                : 50.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Temperature value
                  Text(
                    '${hour.temperature.round()}°',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Bar
                  Container(
                    width: 18,
                    height: normalizedHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.orange,
                          Colors.red,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Hour label
                  SizedBox(
                    height: 11,
                    child: index % 3 == 0
                        ? Text(
                            '${hour.getHour()}h',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white70,
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTemperatureSummary() {
    if (_hourlyData == null || _hourlyData!.isEmpty) {
      return const SizedBox();
    }

    final temps = _hourlyData!.map((e) => e.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final avgTemp = temps.reduce((a, b) => a + b) / temps.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem(
          Icons.arrow_upward,
          'High',
          '${maxTemp.round()}°C',
          Colors.red,
        ),
        _buildSummaryItem(
          Icons.thermostat,
          'Average',
          '${avgTemp.round()}°C',
          Colors.orange,
        ),
        _buildSummaryItem(
          Icons.arrow_downward,
          'Low',
          '${minTemp.round()}°C',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyCard(HourlyModel hour) {
    final isNow = hour.isCurrentHour();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isNow
          ? Colors.white.withOpacity(0.3)
          : Colors.white.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Time
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hour.getFormattedHour(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isNow ? FontWeight.bold : FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (isNow)
                    const Text(
                      'Now',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            // Weather emoji
            Expanded(
              flex: 1,
              child: Text(
                hour.getWeatherEmoji(),
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),

            // Temperature
            Expanded(
              flex: 2,
              child: Text(
                '${hour.temperature.round()}°C',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Humidity
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_drop, color: Colors.lightBlue, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${hour.humidity}%',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Precipitation
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water, color: Colors.blue, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${hour.precipitation.toStringAsFixed(1)}mm',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}