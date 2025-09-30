import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/weather_services.dart';
import 'forecast_screen.dart';
import 'hourly_screen.dart';
import 'comparison_screen.dart';
import 'details_screen.dart';
import 'settings_screen.dart';
import 'trends_screen.dart';
import 'air_quality_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  String _selectedCity = 'London';
  bool _isLoading = false;
  WeatherModel? _weather;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.getWeather(_selectedCity);
      setState(() {
        _weather = weather;
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
        title: const Text('Weather App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlue.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButton<String>(
                      value: _selectedCity,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _weatherService.getCities().map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (newCity) {
                        if (newCity != null) {
                          setState(() {
                            _selectedCity = newCity;
                          });
                          _fetchWeather();
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
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
      return SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
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
                  onPressed: _fetchWeather,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_weather != null) {
      return SingleChildScrollView(
        child: _buildWeatherDisplay(_weather!),
      );
    }

    return const Center(
      child: Text('No data available', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildWeatherDisplay(WeatherModel weather) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            weather.getWeatherEmoji(),
            style: const TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 16),
          Text(
            '${weather.temperature.round()}°C',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weather.getWeatherDescription(),
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weather.cityName,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.white.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.air,
                    'Wind Speed',
                    '${weather.windSpeed} km/h',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.access_time,
                    'Updated',
                    DateFormat('HH:mm').format(weather.time),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Button 1: Refresh
          ElevatedButton.icon(
            onPressed: _fetchWeather,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ),
          const SizedBox(height: 12),
          
          // Button 2: 7-Day Forecast
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForecastScreen(cityName: weather.cityName),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('7-Day Forecast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              minimumSize: const Size(200, 48),
            ),
          ),
          const SizedBox(height: 12),
          
          // Button 3: 24-Hour Forecast
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HourlyScreen(cityName: weather.cityName),
                ),
              );
            },
            icon: const Icon(Icons.schedule),
            label: const Text('24-Hour Forecast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
          ),
          const SizedBox(height: 12),
          
          // Button 4: Compare Cities
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComparisonScreen(),
                ),
              );
            },
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare Cities'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
          ),
          const SizedBox(height: 12),
          
          // Button 5: Detailed Info
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(cityName: weather.cityName),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('Detailed Info'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
          ),
          const SizedBox(height: 12),
          
          // Button 6: Weather Trends
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrendsScreen(cityName: weather.cityName),
                ),
              );
            },
            icon: const Icon(Icons.trending_up),
            label: const Text('Weather Trends'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
          ),
          const SizedBox(height: 12),
          
          // Button 7: Air Quality
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AirQualityScreen(cityName: weather.cityName),
                ),
              );
            },
            icon: const Icon(Icons.air),
            label: const Text('Air Quality'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}