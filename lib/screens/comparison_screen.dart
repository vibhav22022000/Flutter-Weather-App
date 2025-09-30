import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_services.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  Map<String, WeatherModel> _weatherData = {};
  String? _errorMessage;
  
  // Selected cities for comparison
  final List<String> _selectedCities = ['London', 'New York', 'Tokyo', 'Paris'];

  @override
  void initState() {
    super.initState();
    _fetchAllWeather();
  }

  Future<void> _fetchAllWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherData.clear();
    });

    try {
      // Fetch weather for all selected cities in parallel
      final futures = _selectedCities.map((city) => 
        _weatherService.getWeather(city)
      ).toList();

      // Wait for all requests to complete
      final results = await Future.wait(futures);

      // Store results in map
      final Map<String, WeatherModel> weatherMap = {};
      for (int i = 0; i < _selectedCities.length; i++) {
        weatherMap[_selectedCities[i]] = results[i];
      }

      setState(() {
        _weatherData = weatherMap;
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
        title: const Text('City Comparison'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showCitySelector,
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
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading weather data...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
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
                onPressed: _fetchAllWeather,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_weatherData.isNotEmpty) {
      return SafeArea(
        child: Column(
          children: [
            // Header with stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.compare_arrows, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Weather Comparison',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildQuickStats(),
                    ],
                  ),
                ),
              ),
            ),

            // City weather cards
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ..._weatherData.entries.map((entry) {
                        return _buildCityCard(entry.key, entry.value);
                      }).toList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // Refresh button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _fetchAllWeather,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh All'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _showCitySelector,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Cities'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_weatherData.isEmpty) return const SizedBox();

    // ignore: unused_local_variable
    final temps = _weatherData.values.map((w) => w.temperature).toList();
    final hottestCity = _weatherData.entries
        .reduce((a, b) => a.value.temperature > b.value.temperature ? a : b);
    final coldestCity = _weatherData.entries
        .reduce((a, b) => a.value.temperature < b.value.temperature ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          Icons.wb_sunny,
          'Hottest',
          hottestCity.key,
          '${hottestCity.value.temperature.round()}°C',
          Colors.orange,
        ),
        _buildStatItem(
          Icons.ac_unit,
          'Coldest',
          coldestCity.key,
          '${coldestCity.value.temperature.round()}°C',
          Colors.lightBlue,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String city, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        Text(
          city,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCityCard(String cityName, WeatherModel weather) {
    // Determine temperature color
    Color tempColor;
    if (weather.temperature >= 25) {
      tempColor = Colors.red;
    } else if (weather.temperature >= 15) {
      tempColor = Colors.orange;
    } else {
      tempColor = Colors.lightBlue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // City name and emoji
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cityName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        weather.getWeatherEmoji(),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          weather.getWeatherDescription(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Temperature (big and colored)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    '${weather.temperature.round()}°',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: tempColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tempColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      weather.temperature >= 25 ? 'HOT' : 
                      weather.temperature >= 15 ? 'WARM' : 'COLD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: tempColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Wind speed
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Icon(Icons.air, color: Colors.white70, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '${weather.windSpeed.round()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'km/h',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
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

  void _showCitySelector() {
    final allCities = _weatherService.getCities();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Cities to Compare'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: allCities.map((city) {
                  final isSelected = _selectedCities.contains(city);
                  return CheckboxListTile(
                    title: Text(city),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          if (_selectedCities.length < 6) {
                            _selectedCities.add(city);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Maximum 6 cities allowed'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          if (_selectedCities.length > 2) {
                            _selectedCities.remove(city);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Minimum 2 cities required'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchAllWeather();
            },
            child: const Text('Compare'),
          ),
        ],
      ),
    );
  }
}