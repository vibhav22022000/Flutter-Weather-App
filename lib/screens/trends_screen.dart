import 'package:flutter/material.dart';
import '../services/weather_services.dart';

class TrendsScreen extends StatefulWidget {
  final String cityName;

  const TrendsScreen({super.key, required this.cityName});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  List<Map<String, dynamic>>? _trendsData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTrends();
  }

  Future<void> _fetchTrends() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.getWeatherTrends(widget.cityName);
      setState(() {
        _trendsData = data;
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
        title: Text('${widget.cityName} - Weather Trends'),
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
                onPressed: _fetchTrends,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_trendsData != null && _trendsData!.isNotEmpty) {
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
                      _buildTrendChart(),
                      const SizedBox(height: 16),
                      _buildAnalysisCard(),
                      const SizedBox(height: 16),
                      _buildDailyTrendsList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _fetchTrends,
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
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              '7-Day Temperature Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final temps = _trendsData!.map((d) => d['avgTemp'] as double).toList();
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final range = maxTemp - minTemp;

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temperature Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_trendsData!.length, (index) {
                      final day = _trendsData![index];
                      final temp = day['avgTemp'] as double;
                      final normalizedHeight = range > 0
                          ? ((temp - minTemp) / range) * 85 + 15
                          : 50.0;
                      
                      final isToday = index == _trendsData!.length - 1;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${temp.round()}°',
                              style: TextStyle(
                                fontSize: 10,
                                color: isToday ? Colors.yellow : Colors.white,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 30,
                              height: normalizedHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isToday
                                      ? [Colors.yellow, Colors.amber]
                                      : [Colors.cyan, Colors.blue],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 3),
                            SizedBox(
                              height: 12,
                              child: Text(
                                day['dayLabel'],
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isToday ? Colors.yellow : Colors.white70,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    final temps = _trendsData!.map((d) => d['avgTemp'] as double).toList();
    final currentTemp = temps.last;
    final previousTemp = temps[temps.length - 2];
    final weekAgoTemp = temps.first;
    
    final dayChange = currentTemp - previousTemp;
    final weekChange = currentTemp - weekAgoTemp;
    
    String dayTrend = dayChange > 0 ? 'warmer' : dayChange < 0 ? 'cooler' : 'stable';
    String weekTrend = weekChange > 0 ? 'warmer' : weekChange < 0 ? 'cooler' : 'stable';
    
    IconData dayIcon = dayChange > 0 ? Icons.trending_up : 
                       dayChange < 0 ? Icons.trending_down : Icons.trending_flat;
    IconData weekIcon = weekChange > 0 ? Icons.trending_up : 
                        weekChange < 0 ? Icons.trending_down : Icons.trending_flat;
    
    Color dayColor = dayChange > 0 ? Colors.red : 
                     dayChange < 0 ? Colors.blue : Colors.white;
    Color weekColor = weekChange > 0 ? Colors.red : 
                      weekChange < 0 ? Colors.blue : Colors.white;

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTrendItem(
                    dayIcon,
                    'Yesterday',
                    '${dayChange.abs().toStringAsFixed(1)}°',
                    dayTrend,
                    dayColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildTrendItem(
                    weekIcon,
                    'Last Week',
                    '${weekChange.abs().toStringAsFixed(1)}°',
                    weekTrend,
                    weekColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(IconData icon, String label, String value, String trend, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          trend,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDailyTrendsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Daily Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ...List.generate(_trendsData!.length, (index) {
          final day = _trendsData![index];
          final isToday = index == _trendsData!.length - 1;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isToday 
                ? Colors.yellow.withOpacity(0.2)
                : Colors.white.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      day['dayLabel'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday ? Colors.yellow : Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.red, size: 14),
                        Text(
                          ' ${day['maxTemp'].round()}°',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.blue, size: 14),
                        Text(
                          ' ${day['minTemp'].round()}°',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        '${day['avgTemp'].round()}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}