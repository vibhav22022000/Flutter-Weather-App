import 'package:flutter/material.dart';
import '../models/forecast_model.dart';
import '../services/weather_services.dart';

class ForecastScreen extends StatefulWidget {
  final String cityName;

  const ForecastScreen({super.key, required this.cityName});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  List<ForecastModel>? _forecasts;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final forecasts = await _weatherService.getForecast(widget.cityName);
      setState(() {
        _forecasts = forecasts;
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
        title: Text('${widget.cityName} - 7 Day Forecast'),
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
                onPressed: _fetchForecast,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_forecasts != null && _forecasts!.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.white.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Next 7 Days',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _forecasts!.asMap().entries.map((entry) {
                        return _buildForecastCard(entry.value, entry.key);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.blue.withOpacity(0.3),
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: _fetchForecast,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Forecast'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
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

  Widget _buildForecastCard(ForecastModel forecast, int index) {
    final isToday = index == 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isToday 
          ? Colors.white.withOpacity(0.3) 
          : Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Today' : forecast.getDayOfWeek(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${forecast.date.day}/${forecast.date.month}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    forecast.getWeatherEmoji(),
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    forecast.getWeatherDescription(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.arrow_upward, 
                          color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${forecast.maxTemp.round()}°',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.arrow_downward, 
                          color: Colors.blue, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${forecast.minTemp.round()}°',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
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