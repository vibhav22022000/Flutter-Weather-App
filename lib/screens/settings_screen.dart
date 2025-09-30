import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCelsius = true;
  bool _is24Hour = true;
  String _theme = 'Blue';
  bool _notificationsEnabled = true;
  
  final List<String> _themes = ['Blue', 'Purple', 'Green', 'Orange', 'Dark'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Units', Icons.straighten),
                  _buildUnitsSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Appearance', Icons.palette),
                  _buildAppearanceSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Notifications', Icons.notifications),
                  _buildNotificationsSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('About', Icons.info),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsSection() {
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Temperature Unit',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _isCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
              style: const TextStyle(color: Colors.white70),
            ),
            value: _isCelsius,
            onChanged: (bool value) {
              setState(() {
                _isCelsius = value;
              });
              _showSnackBar(
                'Temperature unit changed to ${value ? 'Celsius' : 'Fahrenheit'}',
              );
            },
            secondary: Icon(
              Icons.thermostat,
              color: _isCelsius ? Colors.blue : Colors.orange,
            ),
            activeColor: Colors.blue,
          ),
          const Divider(color: Colors.white24, height: 1),
          SwitchListTile(
            title: const Text(
              'Time Format',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _is24Hour ? '24-hour' : '12-hour',
              style: const TextStyle(color: Colors.white70),
            ),
            value: _is24Hour,
            onChanged: (bool value) {
              setState(() {
                _is24Hour = value;
              });
              _showSnackBar(
                'Time format changed to ${value ? '24-hour' : '12-hour'}',
              );
            },
            secondary: const Icon(
              Icons.access_time,
              color: Colors.cyan,
            ),
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: ListTile(
        leading: const Icon(Icons.color_lens, color: Colors.purple),
        title: const Text(
          'Theme Color',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _theme,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () => _showThemeDialog(),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: SwitchListTile(
        title: const Text(
          'Weather Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _notificationsEnabled ? 'Enabled' : 'Disabled',
          style: const TextStyle(color: Colors.white70),
        ),
        value: _notificationsEnabled,
        onChanged: (bool value) {
          setState(() {
            _notificationsEnabled = value;
          });
          _showSnackBar(
            'Notifications ${value ? 'enabled' : 'disabled'}',
          );
        },
        secondary: Icon(
          _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
          color: _notificationsEnabled ? Colors.green : Colors.grey,
        ),
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.lightBlue),
            title: Text(
              'App Version',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const ListTile(
            leading: Icon(Icons.code, color: Colors.orange),
            title: Text(
              'API Provider',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Open-Meteo',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text(
              'Made with Flutter',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Learning Project',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.amber),
            title: const Text(
              'Report Issues',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {
              _showSnackBar('Feature coming soon!');
            },
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _themes.map((theme) {
              return RadioListTile<String>(
                title: Text(theme),
                value: theme,
                groupValue: _theme,
                onChanged: (String? value) {
                  setState(() {
                    _theme = value!;
                  });
                  Navigator.pop(context);
                  _showSnackBar('Theme changed to $value');
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}