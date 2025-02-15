import 'package:flutter/material.dart';
import 'package:hendshake_application/history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainScreen(),
      routes: {'/history': (context) => const HistoryScreen()},
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String activity = '';
  double price = 0.0;
  String? selectedType;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedType = prefs.getString('selectedType');
      history = (jsonDecode(prefs.getString('history') ?? '[]') as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    });
  }

  Future<void> _fetchActivity() async {
    final url = selectedType == null
        ? 'https://bored.api.lewagon.com/api/activity'
        : 'https://bored.api.lewagon.com/api/activity?type=$selectedType';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        activity = data['activity'];
        price = (data['price'] is int)
            ? (data['price'] as int).toDouble()
            : data['price'] ?? 0.0;
        history.insert(
            0, {'activity': activity, 'price': price, 'type': data['type']});
        if (history.length > 50) history.removeLast();
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('history', jsonEncode(history));
    }
  }

  void _setType(String? type) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedType = type;
      prefs.setString('selectedType', selectedType ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hendshake API App')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedType,
              hint: const Text('Select Activity Type'),
              items: [
                null,
                'education',
                'recreational',
                'social',
                'diy',
                'charity',
                'cooking',
                'relaxation',
                'music',
                'busywork'
              ]
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type ?? 'None'),
                      ))
                  .toList(),
              onChanged: _setType,
              underline: Container(
                height: 2,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            Text('Activity: $activity', style: const TextStyle(fontSize: 18)),
            Text('Price: $price', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchActivity,
              child: const Text('Next'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: {
                  'history': history,
                  'selectedType': selectedType
                });
              },
              child: const Text('History'),
            ),
          ],
        ),
      ),
    );
  }
}
