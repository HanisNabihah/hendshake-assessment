import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final history = args['history'] as List<Map<String, dynamic>>;
    final selectedType = args['selectedType'] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          final isHighlighted =
              item['type'] == selectedType && selectedType != null;
          return ListTile(
            title: Text(item['activity']),
            subtitle: Text('Price: ${item['price']}'),
            tileColor: isHighlighted ? Colors.yellow[200] : null,
          );
        },
      ),
    );
  }
}
